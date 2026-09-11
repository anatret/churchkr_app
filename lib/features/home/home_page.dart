import 'package:cached_network_image/cached_network_image.dart';
import 'package:churchkr/core/theme.dart';
import 'package:churchkr/data/azbyka_client.dart';
import 'package:churchkr/data/azbyka_day_parser.dart';
import 'package:churchkr/data/models.dart';
import 'package:churchkr/features/widgets/chrome.dart';
import 'package:churchkr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<AzbykaDay> _future;
  AzbykaDay? _day;
  Object? _error;
  bool _loading = true;
  DateTime _selected = DateUtils.dateOnly(DateTime.now());
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(_selected));
  }

  void _selectDay(DateTime date) {
    final day = DateUtils.dateOnly(date);
    setState(() {
      _selected = day;
      _visibleMonth = DateTime(day.year, day.month);
    });
    _load(day);
  }

  Future<void> _load(DateTime date) async {
    setState(() {
      _loading = true;
      _error = null;
      _future = context.read<AzbykaClient>().loadDay(date);
    });
    try {
      final day = await _future;
      if (!mounted || date != _selected) return;
      setState(() {
        _day = day;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || date != _selected) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackdropScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.orthodoxCalendar,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: ChurchColors.primaryText,
                      height: 1.1,
                    ),
                  ),
                ),
                const LanguageSwitcher(compact: true),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                if (_error != null && _day == null) ...[
                  _GlassCard(child: Text(l10n.connectionError)),
                  const SizedBox(height: 16),
                ] else if (_day != null) ...[
                  _CalendarHero(
                    date: _selected,
                    day: _day!,
                    onSelect: _selectDay,
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel(l10n.todayEvents),
                  const SizedBox(height: 8),
                  _EventsCard(day: _day!),
                  if (_description(_day!) != null) ...[
                    const SizedBox(height: 16),
                    _SectionLabel(l10n.dayDescription),
                    const SizedBox(height: 8),
                    _GlassCard(
                      child: Text(
                        _description(_day!)!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.45,
                            ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ] else if (_loading) ...[
                  const SizedBox(height: 48),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 16),
                ],
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _GlassCard(
                      child: _MonthCalendar(
                        visibleMonth: _visibleMonth,
                        selected: _selected,
                        onMonthChanged: (month) {
                          setState(() => _visibleMonth = month);
                        },
                        onSelect: _selectDay,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _description(AzbykaDay day) {
    final parts = <String>[
      for (final holiday in day.holidays)
        if (stripHtml(holiday.text).length > 80) stripHtml(holiday.text),
    ];
    if (parts.isEmpty) return null;
    return parts.join('\n\n');
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChurchColors.surfaceSoft,
      elevation: 0,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: ChurchColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
    );
  }
}

class _CalendarHero extends StatelessWidget {
  const _CalendarHero({
    required this.date,
    required this.day,
    required this.onSelect,
  });

  final DateTime date;
  final AzbykaDay day;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;
    final julian = julianDateOf(date);
    final weekday = DateFormat.EEEE(locale).format(date).toUpperCase();
    final oldLabel = DateFormat('d MMMM', locale).format(julian);
    final newLabel = DateFormat('d MMMM', locale).format(date);
    final yesterday = date.subtract(const Duration(days: 1));
    final tomorrow = date.add(const Duration(days: 1));
    final weekColor = _colorFromHex(day.weekColor) ?? const Color(0xFFFF4500);
    final featured = day.holidays.isEmpty ? null : day.holidays.first;
    final notes = <String>[
      if (day.fasting) l10n.fastingDay,
      if (day.fastingNote != null &&
          day.fastingNote!.isNotEmpty &&
          day.fastingNote!.toLowerCase() != 'пост')
        day.fastingNote!,
      if (day.tone != null) l10n.toneNumber(day.tone!),
    ];

    return _GlassCard(
      child: Column(
        children: [
          if (day.images.isNotEmpty) ...[
            _IconRow(images: day.images),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              _DateNavButton(
                label: l10n.yesterday,
                date: yesterday,
                onTap: () => onSelect(yesterday),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StyleDate(
                            caption: l10n.oldStyle,
                            value: oldLabel,
                            align: TextAlign.right,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: FittedBox(
                            child: Text(
                              weekday,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: ChurchColors.primaryText,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _StyleDate(
                            caption: l10n.newStyle,
                            value: newLabel,
                            align: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _DateNavButton(
                label: l10n.tomorrow,
                date: tomorrow,
                onTap: () => onSelect(tomorrow),
                trailing: true,
              ),
            ],
          ),
          if (day.week != null && day.week!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: weekColor, width: 1.4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                day.week!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: weekColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              notes.join('. '),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2B6CB0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (featured != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: featured.url == null || featured.url!.isEmpty
                  ? null
                  : () => _openUrl(featured.url!),
              child: Text(
                featured.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFE53E3E),
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StyleDate extends StatelessWidget {
  const _StyleDate({
    required this.caption,
    required this.value,
    required this.align,
  });

  final String caption;
  final String value;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align == TextAlign.right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          textAlign: align,
          style: const TextStyle(
            fontSize: 11,
            color: ChurchColors.secondaryText,
          ),
        ),
        Text(
          value,
          textAlign: align,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: ChurchColors.primaryText,
          ),
        ),
      ],
    );
  }
}

class _DateNavButton extends StatelessWidget {
  const _DateNavButton({
    required this.label,
    required this.date,
    required this.onTap,
    this.trailing = false,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    final stamp = DateFormat('dd.MM').format(date);
    final children = [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: ChurchColors.primary,
        ),
      ),
      Text(
        stamp,
        style: const TextStyle(
          fontSize: 11,
          color: ChurchColors.secondaryText,
        ),
      ),
    ];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          crossAxisAlignment:
              trailing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow({required this.images});

  final List<AzbykaImage> images;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Row(
        children: [
          for (var i = 0; i < images.length && i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _IconThumb(image: images[i])),
          ],
        ],
      ),
    );
  }
}

class _IconThumb extends StatelessWidget {
  const _IconThumb({required this.image});

  final AzbykaImage image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _IconViewer(image: image),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFC4A574), width: 1.2),
        ),
        child: CachedNetworkImage(
          imageUrl: image.url,
          fit: BoxFit.cover,
          height: 132,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) =>
              const Icon(Icons.image_not_supported_outlined),
        ),
      ),
    );
  }
}

Color? _colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final value = hex.replaceFirst('#', '');
  if (value.length != 6) return null;
  return Color(int.parse('FF$value', radix: 16));
}

Future<void> _openUrl(String url) {
  return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.visibleMonth,
    required this.selected,
    required this.onMonthChanged,
    required this.onSelect,
  });

  final DateTime visibleMonth;
  final DateTime selected;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;
    final monthLabel = DateFormat.yMMMM(locale).format(visibleMonth);
    final first = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      visibleMonth.year,
      visibleMonth.month,
    );
    final leading = (first.weekday + 6) % 7;
    final totalCells = leading + daysInMonth;
    final rows = ((totalCells + 6) ~/ 7);
    final today = DateUtils.dateOnly(DateTime.now());
    final weekdays = List.generate(
      7,
      (index) => DateFormat.E(locale).format(DateTime(2023, 1, 2 + index)),
    );

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => onMonthChanged(
                DateTime(visibleMonth.year, visibleMonth.month - 1),
              ),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                monthLabel[0].toUpperCase() + monthLabel.substring(1),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            TextButton(
              onPressed: () => onSelect(today),
              child: Text(l10n.today),
            ),
            IconButton(
              onPressed: () => onMonthChanged(
                DateTime(visibleMonth.year, visibleMonth.month + 1),
              ),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final name in weekdays)
              Expanded(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ChurchColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (var row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      index: row * 7 + col,
                      leading: leading,
                      daysInMonth: daysInMonth,
                      month: visibleMonth,
                      selected: selected,
                      today: today,
                      onSelect: onSelect,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.index,
    required this.leading,
    required this.daysInMonth,
    required this.month,
    required this.selected,
    required this.today,
    required this.onSelect,
  });

  final int index;
  final int leading;
  final int daysInMonth;
  final DateTime month;
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final dayNumber = index - leading + 1;
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox(height: 40);
    }
    final date = DateTime(month.year, month.month, dayNumber);
    final isSelected = DateUtils.isSameDay(date, selected);
    final isToday = DateUtils.isSameDay(date, today);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: isSelected ? ChurchColors.primary : Colors.transparent,
        shape: CircleBorder(
          side: isToday && !isSelected
              ? const BorderSide(color: ChurchColors.primary)
              : BorderSide.none,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onSelect(date),
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : ChurchColors.primaryText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventsCard extends StatelessWidget {
  const _EventsCard({required this.day});

  final AzbykaDay day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final holidays = day.holidays
        .where((item) => item.title.trim().isNotEmpty)
        .toList();
    final saints = day.saints
        .where((item) => item.name.trim().isNotEmpty)
        .toList();

    if (holidays.isEmpty && saints.isEmpty) {
      return _GlassCard(child: Text(l10n.noEventsToday));
    }

    return _GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (final holiday in holidays)
            ListTile(
              leading: const Icon(Icons.church_outlined, color: ChurchColors.primary),
              title: Text(
                holiday.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: () {
                final text = stripHtml(holiday.text);
                if (text.isEmpty || text.length > 80) return null;
                return Text(text, maxLines: 2, overflow: TextOverflow.ellipsis);
              }(),
              onTap: holiday.url == null || holiday.url!.isEmpty
                  ? null
                  : () => _openUrl(holiday.url!),
            ),
          if (holidays.isNotEmpty && saints.isNotEmpty)
            const Divider(height: 8, indent: 16, endIndent: 16),
          for (final saint in saints)
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined,
                  color: ChurchColors.secondary),
              title: Text(saint.name),
              subtitle: saint.year == null || saint.year!.isEmpty
                  ? null
                  : Text(saint.year!),
              onTap: saint.url == null || saint.url!.isEmpty
                  ? null
                  : () => _openUrl(saint.url!),
            ),
        ],
      ),
    );
  }
}

class _IconViewer extends StatelessWidget {
  const _IconViewer({required this.image});

  final AzbykaImage image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(image.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(imageUrl: image.url),
        ),
      ),
    );
  }
}
