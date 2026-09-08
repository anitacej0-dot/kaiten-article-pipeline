#!/usr/bin/perl
# Грубая самопроверка уникальности рерайта до прогона в text.ru.
#
# Считает, какая доля цепочек слов (шинглов) черновика встречается в тексте-доноре,
# и показывает самые длинные совпадающие куски. Слова приводятся к основе, поэтому
# «команда переехала» и «команды переехали» считаются совпадением.
#
# Использование:
#   perl tools/shingle_check.pl <черновик.md> <донор.txt> [размер шингла]
#
# Донор — ДОСЛОВНЫЙ текст исходной публикации или другой нашей статьи, а не пересказ.
# Выгрузка: curl -sL "<url>" -o page.html, затем конвертация HTML в текст.
#
# Метрика локальная и заведомо ниже процента text.ru: он подсвечивает целыми
# предложениями и допускает неточные совпадения. Ориентироваться нужно на динамику
# («было 18%, стало 7%»), а не на абсолютное число. Гейт ставит только text.ru.

use strict;
use warnings;
use utf8;

binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDERR, ":encoding(UTF-8)");

my ($draft_file, $donor_file, $n) = @ARGV;
$n ||= 4;

unless ($draft_file && $donor_file) {
    die "Использование: perl tools/shingle_check.pl <черновик.md> <донор.txt> [размер шингла]\n";
}

sub read_text {
    my ($path) = @_;
    open my $fh, "<:encoding(UTF-8)", $path or die "Не открывается $path: $!\n";
    local $/;
    my $t = <$fh>;
    close $fh;
    return $t;
}

# Отрезаем самые частые русские окончания, чтобы сравнивать основы, а не словоформы.
my @SUFFIXES = qw(
     иями ыями ами ями иях ыях ах ях ов ев ий ый ое ее ые ие ая яя ою ею ую юю
    ого его ому ему ыми ими ом ем ой ей их ых ешь ете ишь ите ила ило или ыла
    ать ять еть ить ует уют ает ают ит ят ет ют ла ло ли л а я о е ы и у ю ь й
);

sub stem {
    my ($w) = @_;
    for my $s (@SUFFIXES) {
        if (length($w) - length($s) >= 4 && $w =~ /\Q$s\E$/) {
            $w =~ s/\Q$s\E$//;
            last;
        }
    }
    return $w;
}

sub tokenize {
    my ($t) = @_;
    $t = lc $t;
    $t =~ s/ё/е/g;
    $t =~ s/!\[[^\]]*\]\([^)]*\)/ /g;   # картинки
    $t =~ s/\[([^\]]*)\]\([^)]*\)/$1/g; # ссылки
    $t =~ s/[^\p{Cyrillic}\p{Latin}0-9]+/ /g;
    my @words = grep { length($_) > 1 } split /\s+/, $t;
    return @words;
}

my @draft_words = tokenize(read_text($draft_file));
my @donor_words = tokenize(read_text($donor_file));

if (@draft_words < $n) { die "В черновике слишком мало слов\n"; }

my @draft_stems = map { stem($_) } @draft_words;
my @donor_stems = map { stem($_) } @donor_words;

my %donor_shingles;
for my $i (0 .. $#donor_stems - $n + 1) {
    $donor_shingles{ join(" ", @donor_stems[$i .. $i + $n - 1]) } = 1;
}

my $total = 0;
my $hits  = 0;
my @flags;   # 1, если шингл черновика нашелся у донора

for my $i (0 .. $#draft_stems - $n + 1) {
    my $key = join(" ", @draft_stems[$i .. $i + $n - 1]);
    my $hit = exists $donor_shingles{$key} ? 1 : 0;
    push @flags, $hit;
    $total++;
    $hits += $hit;
}

# Собираем подряд идущие совпавшие шинглы в куски текста
my @fragments;
my $i = 0;
while ($i < @flags) {
    if ($flags[$i]) {
        my $start = $i;
        $i++ while $i < @flags && $flags[$i];
        my $len = ($i - $start) + $n - 1;
        push @fragments, { len => $len, text => join(" ", @draft_words[$start .. $start + $len - 1]) };
    } else {
        $i++;
    }
}

@fragments = sort { $b->{len} <=> $a->{len} } @fragments;

my $pct = $total ? sprintf("%.1f", 100 * $hits / $total) : 0;

print "Черновик: $draft_file (", scalar(@draft_words), " слов)\n";
print "Донор:    $donor_file (", scalar(@donor_words), " слов)\n";
print "Шингл:    $n слова(-ов), сравнение по основам\n";
print "-" x 70, "\n";
print "Совпало цепочек: $hits из $total — $pct%\n";
print "Совпадающих кусков от 6 слов: ", scalar(grep { $_->{len} >= 6 } @fragments), "\n";
print "-" x 70, "\n";

my $shown = 0;
for my $f (@fragments) {
    last if $shown >= 20 || $f->{len} < 6;
    printf("[%2d слов] %s\n", $f->{len}, $f->{text});
    $shown++;
}
print "\nСамые длинные куски переписываем целиком: другое построение фразы,\n";
print "другой порядок фактов. Подстановка синонимов процент не двигает.\n";
