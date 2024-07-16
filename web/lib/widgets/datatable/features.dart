import 'package:app/models/feature.dart';
import 'package:app/screens/edit_feature.dart';
import 'package:app/services/feature_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class FeaturesDatatable extends StatefulWidget {
  const FeaturesDatatable({super.key});

  @override
  State<FeaturesDatatable> createState() => _FeaturesDatatableState();
}

class _FeaturesDatatableState extends State<FeaturesDatatable> {
  late Future<List<Feature>> _featuresFuture;

  @override
  void initState() {
    super.initState();
    fetchFeatures();
  }

  void fetchFeatures() {
    setState(() {
      _featuresFuture = FeaturesService.getFeatures();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final columns = [
      l10n.code,
      l10n.enabled,
      '',
    ];

    return FutureBuilder<List<Feature>>(
      future: _featuresFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Error: ${snapshot.error}');
        }

        return DataTable(
          columns: [
            ...columns.map(
              (column) => DataColumn(
                label: Expanded(
                  child: Text(
                    column,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
          ],
          rows: [
            ...snapshot.data!.map((feature) {
              return DataRow(
                cells: [
                  DataCell(Text(feature.code)),
                  DataCell(
                    Switch(
                      value: feature.enabled,
                      onChanged: (value) {
                        FeaturesService.toggleFeature(feature).then(
                          (value) => fetchFeatures(),
                        );
                      },
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        context.goNamed(EditFeatureScreen.routeName,
                            pathParameters: {
                              'featureCode': feature.code,
                            });
                      },
                    ),
                  )
                ],
              );
            })
          ],
        );
      },
    );
  }
}
