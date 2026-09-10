#!/usr/bin/perl
# Механический слой AI-предредактуры без установки Vale.
#
# Прогоняет правила из styles/Kaiten/*.yml по тексту статьи и печатает находки
# с номерами строк. Уровни те же, что у Vale: error (HARD, блокирует сдачу),
# warning, suggestion.
#
# Использование:
#   perl tools/vale_lite.pl <файл.md>
#   perl tools/vale_lite.pl <файл.md> --start '^# 13 цехов' --end '^## Self-check'
#
# Флаги --start и --end вырезают тело статьи, чтобы служебные блоки (теги, чек-листы
# автора, комментарии) не попадали в проверку.
#
# Скрипт не заменяет Vale целиком: он проверяет ровно те правила, что лежат
# в styles/Kaiten/. Если Vale поставят, гонять надо им.

use strict;
use warnings;
use utf8;

use Encode qw(decode_utf8);

binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDERR, ":encoding(UTF-8)");

# Аргументы приходят байтами; без декодирования кириллица в --start/--end не совпадет
@ARGV = map { decode_utf8($_) } @ARGV;

my ($file, %opt);
for (my $i = 0; $i < @ARGV; $i++) {
    if    ($ARGV[$i] eq "--start") { $opt{start} = $ARGV[++$i] }
    elsif ($ARGV[$i] eq "--end")   { $opt{end}   = $ARGV[++$i] }
    else                           { $file = $ARGV[$i] }
}
die "Использование: perl tools/vale_lite.pl <файл.md> [--start RE] [--end RE]\n" unless $file;

open my $fh, "<:encoding(UTF-8)", $file or die "Не открывается $file: $!\n";
my @all = <$fh>;
close $fh;

# Вырезаем тело статьи
my @lines;
my $on = $opt{start} ? 0 : 1;
for my $i (0 .. $#all) {
    my $l = $all[$i];
    $on = 1 if $opt{start} && $l =~ /$opt{start}/;
    last  if $on && $opt{end} && $l =~ /$opt{end}/ && ($opt{start} ? $i > 0 : 1);
    push @lines, [$i + 1, $l] if $on;
}
die "По --start/--end ничего не нашлось\n" unless @lines;

# --- Правила из styles/Kaiten/ ---

my @rules = (
    # NoYo.yml
    { level => "error", name => "NoYo",
      re => qr/ё/, msg => 'буква «ё» — по редполитике Kaiten пишем «е»' },

    # Lexicon.yml
    { level => "error", name => "Lexicon",
      re => qr/\bфункционал(а|ом|е|у|ы)?\b/i, msg => '«функционал» → «функциональность»' },
    { level => "error", name => "Lexicon",
      re => qr/для того,?\s+чтобы/i, msg => '«для того чтобы» → «чтобы»' },

    # AgileTerms.yml
    { level => "error", name => "AgileTerms",
      re => qr/(Эджайл|Аджайл)/i, msg => '→ «Agile»' },
    { level => "error", name => "AgileTerms",
      re => qr/Scrum-метод/i, msg => '→ «Scrum-фреймворк»' },
    { level => "error", name => "AgileTerms",
      re => qr/Канбан-фреймворк/i, msg => '→ «Канбан-метод»' },

    # Positioning.yml
    { level => "error", name => "Positioning",
      re => qr/(Кайтен|Kaiten)[^.!?]{0,30}трекер задач/i, msg => 'Kaiten — не «трекер задач»' },
    { level => "error", name => "Positioning",
      re => qr/трекер задач[^.!?]{0,30}(Кайтен|Kaiten)/i, msg => 'Kaiten — не «трекер задач»' },
    { level => "error", name => "Positioning",
      re => qr/бесплатн(ый|ого|ым) таск-трекер/i, msg => 'допустимо только про тариф Free' },
    { level => "error", name => "Positioning",
      re => qr/сервис для (небольших|маленьких) компаний/i, msg => 'Kaiten подходит и крупным' },

    # Имя бренда в кавычках (forbidden_phrases, HARD)
    { level => "error", name => "BrandQuotes",
      re => qr/[«"](Кайтен|Kaiten)[»"]/, msg => 'имя бренда пишем без кавычек' },

    # Anglicisms.yml
    { level => "warning", name => "Anglicisms",
      re => qr/\bтаск(а|и|ов|ам|ами|е)?\b/i, msg => '→ «задача», «карточка»' },
    { level => "warning", name => "Anglicisms",
      re => qr/\bфич(а|и|у|ей|ами|е)?\b/i, msg => '→ «функция», «возможность»' },
    { level => "warning", name => "Anglicisms",
      re => qr/\bколл\b/i, msg => '→ «звонок», «встреча»' },
    { level => "warning", name => "Anglicisms",
      re => qr/\bаттач(а|ем|ить|ил)?\b/i, msg => '→ «файл», «вложение»' },

    # Bureaucratese.yml
    { level => "warning", name => "Bureaucratese",
      re => qr/в целях/i, msg => '→ «чтобы»' },
    # Границы слова обязательны: без них «явля» ловится внутри «появляется»
    { level => "warning", name => "Bureaucratese",
      re => qr/\bосуществля(ть|ем|ет|ли)\b/i, msg => '→ живой глагол' },
    { level => "warning", name => "Bureaucratese",
      re => qr/\bявля(ется|емся)\b/i, msg => '→ «быть» или перестроить фразу' },
    { level => "warning", name => "Bureaucratese",
      re => qr/в случае если/i, msg => '→ «если»' },
    { level => "warning", name => "Bureaucratese",
      re => qr/на сегодняшний день/i, msg => '→ «сегодня»' },
    { level => "warning", name => "Bureaucratese",
      re => qr/в связи с тем,?\s+что/i, msg => '→ «потому что»' },

    # Cliches.yml
    { level => "warning", name => "Cliches",
      re => qr/как снег на голову|плачевны(е|х) последстви|были затронуты вопрос|революционн(ое|ый|ая|ые)|не побоюсь этого слова|в современном мире|ни для кого не секрет/i,
      msg => 'журналистский штамп — переформулируйте' },

    # Intensifiers.yml
    { level => "suggestion", name => "Intensifiers",
      re => qr/\bсам(ый|ая|ое|ые|ого|ую)\b/i, msg => 'усилитель — подтвердите фактом или уберите' },
    { level => "suggestion", name => "Intensifiers",
      re => qr/\bнаиболее\b/i, msg => 'усилитель — подтвердите фактом или уберите' },
    { level => "suggestion", name => "Intensifiers",
      re => qr/\bлучш(ий|ая|ее|ие|его)\b/i, msg => 'усилитель — подтвердите фактом или уберите' },
    { level => "suggestion", name => "Intensifiers",
      re => qr/\bуникальн(ый|ая|ое|ые)\b/i, msg => 'усилитель — подтвердите фактом или уберите' },
);

my %found = (error => [], warning => [], suggestion => []);

for my $row (@lines) {
    my ($ln, $text) = @$row;
    next if $text =~ /^\s*```/;
    my $clean = $text;
    $clean =~ s/`[^`]*`//g;              # инлайн-код и служебные пометки
    $clean =~ s/\]\([^)]*\)/]/g;         # url в ссылках
    for my $r (@rules) {
        if (my ($m) = $clean =~ /($r->{re})/) {
            push @{ $found{ $r->{level} } }, { line => $ln, rule => $r->{name}, hit => $m, msg => $r->{msg} };
        }
    }
}

# --- SentenceLength.yml: средняя длина предложения ---

my $body = join "", map { $_->[1] } @lines;
$body =~ s/`[^`]*`//g;
$body =~ s/^\s*[-*|#>].*$//gm;           # списки, таблицы, заголовки, цитаты
$body =~ s/\]\([^)]*\)/]/g;
my @sentences = grep { /\p{Cyrillic}/ } split /(?<=[.!?])\s+/, $body;
my ($tw, $ns, @long) = (0, 0);
for my $s (@sentences) {
    my @w = grep { /\p{Cyrillic}|\p{Latin}|\d/ } split /\s+/, $s;
    next unless @w;
    $tw += scalar @w; $ns++;
    push @long, { n => scalar @w, s => $s } if @w > 25;
}
my $avg = $ns ? $tw / $ns : 0;
@long = sort { $b->{n} <=> $a->{n} } @long;

# --- Вывод ---

printf("Файл: %s\n", $file);
printf("Проверено строк тела: %d\n", scalar @lines);
print "-" x 72, "\n";

for my $lvl (qw(error warning suggestion)) {
    my $list = $found{$lvl};
    my $label = { error => "ERROR (HARD, блокирует)", warning => "WARNING", suggestion => "SUGGESTION" }->{$lvl};
    printf("%s: %d\n", $label, scalar @$list);
    for my $f (@$list) {
        printf("  стр.%-4d [%s] «%s» — %s\n", $f->{line}, $f->{rule}, $f->{hit}, $f->{msg});
    }
    print "\n" if @$list;
}

print "-" x 72, "\n";
printf("SentenceLength: предложений %d, средняя длина %.1f слова (порог 15) — %s\n",
    $ns, $avg, $avg > 15 ? "ВЫШЕ ПОРОГА" : "в норме");
if (@long) {
    printf("Предложения длиннее 25 слов: %d\n", scalar @long);
    for my $i (0 .. ($#long > 4 ? 4 : $#long)) {
        my $s = $long[$i]{s}; $s =~ s/\s+/ /g;
        $s = substr($s, 0, 110) . "…" if length($s) > 110;
        printf("  [%d слов] %s\n", $long[$i]{n}, $s);
    }
}

print "-" x 72, "\n";
my $errs = scalar @{ $found{error} };
print $errs ? "ГЕЙТ: не пройден — есть HARD-нарушения\n" : "ГЕЙТ: HARD-нарушений нет\n";
exit($errs ? 1 : 0);
