#!/usr/bin/perl
# Проверка прямых цитат героя в кейсе.
#
# Находит в статье прямые цитаты «…» (от 8 слов), сверяет каждую с исходником дословно и
# проверяет минимум — по редправилам в кейсе не меньше трех цитат. Заодно считает, какую
# долю текста занимают цитаты (они снижают уникальность), и первое лицо вне цитат.
#
# Использование:
#   perl tools/quote_check.pl <статья.md> <исходник.md>
#   perl tools/quote_check.pl <статья.md> <исходник.md> --start '^# Заголовок' --end '^## Self-check'
#   perl tools/quote_check.pl <статья.md> <исходник.md> --min 3 --min-words 8
#
# «Дословно» считается по словам: без учета регистра, «ё/е», кавычек, тире и знаков
# препинания. Замена хотя бы одного слова цитату не пропустит. Короткие «названия» и
# обрывки фраз короче порога в цитаты не засчитываются.

use strict;
use warnings;
use utf8;
use Encode qw(decode_utf8);

binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDERR, ":encoding(UTF-8)");

@ARGV = map { decode_utf8($_) } @ARGV;

my (@files, %opt);
for (my $i = 0; $i < @ARGV; $i++) {
    if    ($ARGV[$i] eq "--start")     { $opt{start}     = $ARGV[++$i] }
    elsif ($ARGV[$i] eq "--end")       { $opt{end}       = $ARGV[++$i] }
    elsif ($ARGV[$i] eq "--min")       { $opt{min}       = $ARGV[++$i] }
    elsif ($ARGV[$i] eq "--min-words") { $opt{min_words} = $ARGV[++$i] }
    else                               { push @files, $ARGV[$i] }
}
my ($draft_file, $source_file) = @files;
die "Использование: perl tools/quote_check.pl <статья.md> <исходник.md> [--start RE] [--end RE] [--min 3] [--min-words 8]\n"
    unless $draft_file && $source_file;

my $min       = $opt{min}       // 3;
my $min_words = $opt{min_words} // 8;

sub slurp {
    my ($path) = @_;
    open my $fh, "<:encoding(UTF-8)", $path or die "Не открывается $path: $!\n";
    local $/;
    my $t = <$fh>;
    close $fh;
    $t =~ s/\r\n/\n/g;
    return $t;
}

sub words {
    my ($s) = @_;
    $s = lc $s;
    $s =~ tr/ё/е/;
    return ($s =~ /(\p{L}+|\d+)/g);
}

# --- Тело статьи ---

my @lines = split /\n/, slurp($draft_file), -1;
my @body;
my $on = $opt{start} ? 0 : 1;
for my $l (@lines) {
    $on = 1 if $opt{start} && $l =~ /$opt{start}/;
    last if $on && $opt{end} && @body && $l =~ /$opt{end}/;
    push @body, $l if $on;
}
die "По --start/--end ничего не нашлось\n" unless @body;

my $body = join "\n", @body;
$body =~ s/`[^`]*`//g;            # инлайн-код и служебные пометки
$body =~ s/\]\([^)]*\)/]/g;       # адреса ссылок, текст ссылки остается

# --- Внешние «…» с учетом вложенности ---

my @spans;
{
    my ($depth, $start) = (0, 0);
    my @chars = split //, $body;
    for my $i (0 .. $#chars) {
        if ($chars[$i] eq "«") {
            $start = $i if $depth == 0;
            $depth++;
        } elsif ($chars[$i] eq "»" && $depth > 0) {
            $depth--;
            push @spans, [$start, $i] if $depth == 0;
        }
    }
}

my $source_norm = " " . join(" ", words(slurp($source_file))) . " ";

my (@quotes, $quoted_words);
for my $sp (@spans) {
    my ($s, $e) = @$sp;
    my $text = substr($body, $s + 1, $e - $s - 1);
    my @w = words($text);
    next if @w < $min_words;

    my $needle = " " . join(" ", @w) . " ";
    my $found  = index($source_norm, $needle) >= 0;

    my @flags;
    push @flags, "буква «ё» — заменить на «е»"             if $text =~ /ё/;
    push @flags, "«функционал» — HARD, выбрать другую цитату" if $text =~ /функционал(?!ьн)/i;
    push @flags, "«для того чтобы» — HARD, выбрать другую"   if $text =~ /для того,?\s+чтобы/i;
    push @flags, "вложенные кавычки должны быть „лапками“"   if $text =~ /«/;

    (my $preview = $text) =~ s/\s+/ /g;
    $preview = substr($preview, 0, 90) . "…" if length($preview) > 90;

    push @quotes, { n => scalar @w, found => $found, preview => $preview, flags => \@flags };
    $quoted_words += @w;
}

# --- Первое лицо вне цитат ---

my $outside = $body;
for my $sp (reverse @spans) {
    my ($s, $e) = @$sp;
    substr($outside, $s, $e - $s + 1) = " " x ($e - $s + 1);
}
my @first = ($outside =~ /(?<!\p{L})(мы|нас|нам|нами|наш\p{L}*)(?!\p{L})/gi);

my $total_words = scalar(() = words($body));
my $verified    = grep { $_->{found} } @quotes;
my $share       = $total_words ? 100 * ($quoted_words // 0) / $total_words : 0;

# --- Вывод ---

printf("Статья:   %s\n", $draft_file);
printf("Исходник: %s\n", $source_file);
printf("Цитатой считается «…» от %d слов\n", $min_words);
print "-" x 72, "\n";

my $i = 0;
for my $q (@quotes) {
    $i++;
    printf("%d. [%2d слов] %s %s\n", $i, $q->{n}, $q->{found} ? "✓ дословно" : "✗ НЕТ В ИСХОДНИКЕ", $q->{preview});
    printf("   ⚠ %s\n", $_) for @{ $q->{flags} };
}
print "Прямых цитат не найдено\n" unless @quotes;

print "-" x 72, "\n";
printf("Цитат: %d, подтверждено дословно: %d, минимум: %d\n", scalar @quotes, $verified, $min);
printf("Доля цитат в тексте: %.1f%% (%d из %d слов) — цитаты снижают уникальность\n",
    $share, $quoted_words // 0, $total_words);
printf("Первое лицо вне цитат: %d%s\n", scalar @first,
    @first ? " (" . join(", ", @first) . ")" : "");
print "-" x 72, "\n";

my @fail;
push @fail, "подтверждено дословно $verified из минимума $min" if $verified < $min;
push @fail, "есть цитаты, которых нет в исходнике"            if $verified < @quotes;
push @fail, "первое лицо вне цитат"                           if @first;
push @fail, "замечания к цитатам"                             if grep { @{ $_->{flags} } } @quotes;

if (@fail) {
    print "ГЕЙТ: не пройден — ", join("; ", @fail), "\n";
    exit 1;
}
print "ГЕЙТ: пройден\n";
exit 0;
