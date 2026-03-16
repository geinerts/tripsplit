part of 'trips_page.dart';

extension _TripsPageEditDialog on _TripsPageState {
  Future<_EditTripResult?> _showEditTripDialog(Trip trip) async {
    final t = context.l10n;
    final nameController = TextEditingController(text: trip.name.trim());
    Uint8List? selectedImageBytes;
    String? selectedImageName;
    String? errorText;

    try {
      return await showDialog<_EditTripResult>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text('${t.editAction} ${t.tripTitleShort}'),
                content: SizedBox(
                  width: 430,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: t.tripNameLabel,
                            hintText: t.tripNameHint,
                          ),
                          onChanged: (_) {
                            setDialogState(() {
                              errorText = null;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await _pickTripImageForUpload();
                            if (!mounted || !context.mounted) {
                              return;
                            }
                            if (picked == null) {
                              return;
                            }
                            setDialogState(() {
                              selectedImageBytes = picked.bytes;
                              selectedImageName = picked.fileName;
                            });
                          },
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Choose new trip image (optional)'),
                        ),
                        if (selectedImageName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Selected image: $selectedImageName',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ] else if ((trip.imageUrl ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Trip image already set.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (errorText != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t.cancelAction),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final nextName = nameController.text.trim();
                      if (nextName.length < 2 || nextName.length > 120) {
                        setDialogState(() {
                          errorText = t.tripNameLengthValidation;
                        });
                        return;
                      }
                      Navigator.of(context).pop(
                        _EditTripResult(
                          name: nextName,
                          imageFileName: selectedImageName,
                          imageBytes: selectedImageBytes,
                        ),
                      );
                    },
                    child: Text(t.saveAction),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
    }
  }
}
