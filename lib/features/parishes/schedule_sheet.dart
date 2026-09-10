import 'package:churchkr/core/theme.dart';
import 'package:churchkr/data/church_repository.dart';
import 'package:churchkr/data/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ScheduleSheet extends StatelessWidget {
  const ScheduleSheet({super.key, required this.pid});

  final String pid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = context.read<ChurchRepository>();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (context, controller) {
        return StreamBuilder<List<ScheduleRecord>>(
          stream: repo.schedulesForPid(pid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data ?? const [];
            if (items.isEmpty) {
              return Center(child: Text(l10n.emptySchedule));
            }
            return ListView.builder(
              controller: controller,
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final when = item.dateTime == null
                    ? ''
                    : DateFormat.yMMMEd(l10n.localeName)
                        .add_Hm()
                        .format(item.dateTime!);
                return Card(
                  color: ChurchColors.surfaceSoft,
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: when.isEmpty ? null : Text(when),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
