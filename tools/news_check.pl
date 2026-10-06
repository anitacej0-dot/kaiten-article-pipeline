#!/usr/bin/perl
# Механическая проверка новости для внешней площадки (по умолчанию — Executive.ru).
#
# Читает черновик, разложенный по разделам «## Заголовок», «## Анонс», «## Текст»
# (так устроены шаблон templates/executive_news_draft.md и примеры в
# external_platforms/e-xecutive/examples/), и проверяет то, что можно посчитать: длину
# заголовка и анонса, объем текста, число внешних ссылок, третье лицо, «ё»,
# незакрытые вопросы [НУЖНО УТОЧНИТЬ], анонсы мероприятий и справку о компании.
#
# Использование:
#   perl tools/news_check.pl <04_draft.md>
#   perl tools/news_check.pl <04_draft.md> --title-max 70 --lead-max 160 \
#        --body-min 2000 --body-max 3000 --links-max 1
#
# Пороги по умолчанию — правила Executive.ru
# (external_platforms/e-xecutive/platform_rules.md). Для другой площадки передать свои.
#
# Скрипт не заменяет вычитку: смысл, факты и тон проверяет QA по реестру фактуры.
# Уровни: ERROR — модерация площадки откажет или редполитика запрещает, WARN — проверить
# глазами, NOTE — подсказка. Код выхода 1, если есть хоть одна ошибка.

use strict;
use warnings;
use utf8;

use Encode qw(decode_utf8);

binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDERR, ":encoding(UTF-8)");

@ARGV = map { decode_utf8($_) } @ARGV;

my %opt = (title_max => 70, lead_max => 160, body_min => 2000, body_max => 3000, links_max => 1);
my $file;
for (my $i = 0; $i < @ARGV; $i++) {
    if ($ARGV[$i] =~ /^--(title-max|lead-max|body-min|body-max|links-max)$/) {
        (my $k = $1) =~ tr/-/_/;
        $opt{$k} = $ARGV[++$i];
    }
    else { $file = $ARGV[$i] }
}
die "Использование: perl tools/news_check.pl <черновик.md> [--title-max 70] [--lead-max 160]"
  . " [--body-min 2000] [--body-max 3000] [--links-max 1]\n" unless $file;

open my $fh, "<:encoding(UTF-8)", $file or die "Не открывается $file: $!\n";
my @all = <$fh>;
close $fh;

# --- Раскладываем черновик по разделам второго уровня ---

my (%sec, $cur, $in_comment);
for my $i (0 .. $#all) {
    my $l = $all[$i];
    chomp $l;
    # HTML-комментарии — подсказки шаблона, в текст новости они не входят
    if ($in_comment) { $in_comment = 0 if $l =~ /-->/; next }
    $l =~ s/<!--.*?-->//g;
    if ($l =~ /<!--/) { $l =~ s/<!--.*//; $in_comment = 1 }
    if ($l =~ /^##\s+(.+?)\s*$/) { $cur = $1; $sec{$cur} //= []; next }
    if ($l =~ /^#\s/)            { $cur = undef; next }
    push @{ $sec{$cur} }, [$i + 1, $l] if defined $cur;
}
for my $need ("Заголовок", "Анонс", "Текст") {
    die "В файле нет раздела «## $need». Черновик должен идти по шаблону templates/executive_news_draft.md\n"
        unless $sec{$need};
}

# То, что увидит читатель: без markdown-разметки
sub plain {
    my $t = shift;
    $t =~ s/!\[[^\]]*\]\([^)]*\)//g;            # картинки
    $t =~ s/\[([^\]]*)\]\([^)]*\)/$1/g;          # ссылки → анкор
    $t =~ s/^\s*(?:[-*+]|\d+[.)])\s+//;          # маркеры списков
    $t =~ s/^\s*>\s?//;                          # цитаты-блоки
    $t =~ s/^#{3,6}\s+//;                        # подзаголовки внутри текста
    $t =~ s/\*\*//g;
    $t =~ s/(?<!\S)\*(?=\S)|(?<=\S)\*(?!\S)//g;  # курсив
    $t =~ s/^\s+|\s+$//g;
    return $t;
}

sub lines_of { grep { $_->[1] =~ /\S/ } @{ $sec{ $_[0] } } }

my @issues;    # [уровень, строка, сообщение]
sub issue { push @issues, [@_] }

# --- Заголовок ---

my @title_lines = lines_of("Заголовок");
my $title = @title_lines ? plain($title_lines[0][1]) : "";
my $title_len = length $title;
my $tln = @title_lines ? $title_lines[0][0] : 0;
issue("ERROR", 0, "Заголовок пустой") unless $title_len;
issue("ERROR", $tln, "В разделе «Заголовок» больше одной строки: варианты держим в «Служебном»")
    if @title_lines > 1;
issue("ERROR", $tln, "Заголовок $title_len знаков, на площадке максимум $opt{title_max}")
    if $title_len > $opt{title_max};
issue("ERROR", $tln, "Точка в конце заголовка") if $title =~ /\.$/;
issue("WARN", $tln, "Вопрос в заголовке: новость сообщает факт, а не спрашивает") if $title =~ /\?$/;

# Глагол обязателен. Морфологии у скрипта нет, поэтому только подсказка по окончаниям
my @verbish = grep { length($_) > 3 && /(?:л|ла|ло|ли|лся|лась|лось|лись|ет|ит|ут|ют|ат|ят|ется|ится|ются|ятся)$/i }
              ($title =~ /([\p{L}-]+)/g);
issue("WARN", $tln, "Не видно глагола. На Executive.ru заголовок обязан его содержать — проверь")
    if $title_len && !@verbish;

# --- Анонс ---

my @lead_lines = lines_of("Анонс");
my $lead = join " ", map { plain($_->[1]) } @lead_lines;
my $lead_len = length $lead;
my $lln = @lead_lines ? $lead_lines[0][0] : 0;
issue("ERROR", 0, "Анонс пустой") unless $lead_len;
issue("ERROR", $lln, "Анонс $lead_len знаков, на площадке максимум $opt{lead_max}")
    if $lead_len > $opt{lead_max};
issue("WARN", $lln, "Анонс повторяет заголовок, а должен его уточнять")
    if $lead_len && $title_len && index(lc $lead, lc $title) >= 0;

# --- Текст ---

my @body_lines = lines_of("Текст");
my $body_len = 0;
$body_len += length plain($_->[1]) for @body_lines;
my $body_text = join "\n", map { plain($_->[1]) } @body_lines;

if    (!$body_len)                   { issue("ERROR", 0, "Текст пустой") }
elsif ($body_len < $opt{body_min})   { issue("WARN", 0, "Текст $body_len знаков с пробелами, оптимум площадки $opt{body_min}–$opt{body_max}") }
elsif ($body_len > $opt{body_max})   { issue("WARN", 0, "Текст $body_len знаков с пробелами, оптимум площадки $opt{body_min}–$opt{body_max}") }

# Внешние ссылки: markdown-ссылки и голые адреса. Ссылки на саму площадку не считаем
my $links = 0;
for my $bl (@body_lines) {
    my $l = $bl->[1];
    my @md = ($l =~ /\]\((https?:\/\/[^)\s]+)\)/g);
    (my $rest = $l) =~ s/\]\([^)]*\)//g;
    my @bare = ($rest =~ /(https?:\/\/\S+)/g);
    $links += grep { !/e-xecutive\.ru/ } @md, @bare;
}
issue("ERROR", 0, "Внешних ссылок в тексте $links, на площадке можно не больше $opt{links_max}")
    if $links > $opt{links_max};
for my $bl (@title_lines, @lead_lines) {
    issue("ERROR", $bl->[0], "Ссылка в заголовке или анонсе") if $bl->[1] =~ /https?:\/\/|\]\(/;
}

# --- Построчные проверки заголовка, анонса и текста ---

my $person = qr/\b(мы|нас|нам|нами|наш|наша|наше|наши|нашего|нашей|нашему|нашим|нашими|наших|нашу|
                   вы|вас|вам|вами|ваш|ваша|ваше|ваши|вашего|вашей|вашему|вашим|вашими|ваших|вашу)\b/xi;

for my $bl (@title_lines, @lead_lines, @body_lines) {
    my ($n, $raw) = @$bl;
    my $l = plain($raw);

    issue("ERROR", $n, "Буква «ё» — по редполитике Кайтена пишем «е»") if $l =~ /ё/i;
    while ($raw =~ /\[(НУЖНО [^\]]*|НУЖЕН [^\]]*|НУЖНА [^\]]*)\]/g) {
        issue("ERROR", $n, "Открытый вопрос: [$1]");
    }

    # Первое и второе лицо вне прямой речи: в цитатах спикера «мы» допустимо
    (my $outside = $l) =~ s/«[^«»]*»//g;
    while ($outside =~ /$person/g) {
        issue("ERROR", $n, "«$1» вне цитаты: новость пишется от третьего лица, к читателю на «вы» не обращаемся");
    }
    issue("WARN", $n, "«$1» — первое лицо, площадка его не пропускает")
        if $outside =~ /\b(публикуем|представляем|рады сообщить|приглашаем)\b/i;

    issue("WARN", $n, "Несклоненное «в Кайтен» — по редполитике «в Кайтене»")
        if $l =~ /\b[Вв]\s+Кайтен(?![\p{L}])/;
    issue("WARN", $n, "Похоже на анонс мероприятия: такие новости площадка не публикует, для них раздел «Мероприятия»")
        if $l =~ /\b(состоится|состоятся|пройдет|пройдут|регистрация открыта|приглашает)\b/i;
    issue("WARN", $n, "Восклицательный знак вне цитаты") if $outside =~ /!/;
}

for my $bl (@body_lines) {
    issue("WARN", $bl->[0], "Похоже на справку о компании: площадка просит ее не ставить")
        if plain($bl->[1]) =~ /^(О компании|Справка|О Кайтене|О Kaiten)\b/i;
}

# --- Длинные предложения: подсказка, а не запрет ---

my @long;
for my $s (split /(?<=[.!?…])\s+/, $body_text) {
    my $words = () = $s =~ /[\p{L}\d]+(?:-[\p{L}\d]+)*/g;
    push @long, [$words, $s] if $words > 25;
}
issue("NOTE", 0, sprintf("Длинное предложение (%d слов): «%s…»", $_->[0], substr($_->[1], 0, 70))) for @long;

# --- Отчет ---

print "Проверка новости: $file\n\n";
printf "Заголовок: %d знаков из %d — %s\n", $title_len, $opt{title_max}, $title_len <= $opt{title_max} ? "ок" : "длинно";
printf "  «%s»\n", $title;
printf "  похоже на глагол: %s\n", @verbish ? join(", ", map {"«$_»"} @verbish) : "не найдено";
printf "Анонс: %d знаков из %d — %s\n", $lead_len, $opt{lead_max}, $lead_len <= $opt{lead_max} ? "ок" : "длинно";
printf "Текст: %d знаков с пробелами, оптимум %d–%d — %s\n", $body_len, $opt{body_min}, $opt{body_max},
    ($body_len >= $opt{body_min} && $body_len <= $opt{body_max}) ? "ок" : "вне оптимума";
printf "Внешних ссылок в тексте: %d из %d допустимых\n\n", $links, $opt{links_max};

my %count;
for my $is (sort { order($a->[0]) <=> order($b->[0]) || $a->[1] <=> $b->[1] } @issues) {
    my ($lvl, $n, $msg) = @$is;
    $count{$lvl}++;
    printf "%-5s %s%s\n", $lvl, ($n ? "стр. $n: " : ""), $msg;
}
sub order { return { ERROR => 0, WARN => 1, NOTE => 2 }->{ $_[0] } }

printf "\nИтог: ошибок %d, предупреждений %d, подсказок %d\n",
    $count{ERROR} // 0, $count{WARN} // 0, $count{NOTE} // 0;
print $count{ERROR} ? "Не отправлять: исправить ошибки.\n" : "Механика пройдена. Дальше — сверка фактов и вычитка.\n";
exit($count{ERROR} ? 1 : 0);
