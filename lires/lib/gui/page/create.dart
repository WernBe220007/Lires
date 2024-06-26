import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lires/helpers/api_fetcher.dart';
import 'package:http/http.dart';
import 'package:lires/structures/priveleges.dart';

class CreateWizard extends StatefulWidget {
  const CreateWizard({super.key});

  @override
  State<CreateWizard> createState() => CreateWizardState();
}

enum CreateWizardTypes { roomReservation, dayTrip, longTrip }

class CreateWizardState extends State<CreateWizard> {
  int step = 0;
  String appBarTitle = "Neuer Tagesausflug";
  CreateWizardTypes wizardType = CreateWizardTypes.dayTrip;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> costsKey = GlobalKey<FormState>();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool costs = true;
  bool costsTravel = false;
  bool costsDaily = false;
  bool costsViaBuisnessCard = false;

  Future<void> _selectStartDate(BuildContext context, bool dayTrip) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 36500)));
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
      if (dayTrip) {
        setState(() {
          endDate = picked;
        });
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context, bool dayTrip) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dayTrip ? startDate : endDate,
        firstDate: startDate.subtract(const Duration(days: 1)),
        lastDate: dayTrip
            ? startDate.add(const Duration(days: 1))
            : DateTime.now().add(const Duration(days: 3650)));
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: startDate.hour, minute: startDate.minute),
    );
    if (picked != null) {
      setState(() {
        startDate = DateTime(startDate.year, startDate.month, startDate.day,
            picked.hour, picked.minute);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: endDate.hour, minute: endDate.minute),
    );
    if (picked != null) {
      setState(() {
        endDate = DateTime(endDate.year, endDate.month, endDate.day,
            picked.hour, picked.minute);
      });
    }
  }

  void onStepContinue() async {
    //var scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      step++;
    });
  }

  void onStepBack() async {
    setState(() {
      step--;
    });
  }

  void onStepReset() async {
    setState(() {
      step = 0;
    });
  }

  List<Widget> createButtonsForStep(ControlsDetails details, int step) {
    List<Widget> widgets = [];

    if (step != 4) {
      widgets.add(FilledButton(
        onPressed: onStepContinue,
        child: const Text("Weiter"),
      ));
    } else {
      widgets.add(FilledButton(
        onPressed: onStepReset,
        child: const Text("Fertig"),
      ));
    }

    if (step != 0) {
      widgets.add(const SizedBox(width: 8));
      widgets.add(FilledButton.tonal(
        onPressed: onStepBack,
        child: const Text("Zurück"),
      ));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stepper(
                onStepTapped: (value) => setState(() => step = value),
                physics: const ClampingScrollPhysics(),
                currentStep: step,
                controlsBuilder:
                    (BuildContext context, ControlsDetails details) {
                  return Column(children: [
                    const SizedBox(height: 8),
                    Row(
                      children: createButtonsForStep(details, step),
                    )
                  ]);
                },
                steps: [
                  Step(
                      title: const Text('Typ'),
                      content: Card(
                        child: ListTile(
                            title: SegmentedButton<CreateWizardTypes>(
                          segments: const [
                            ButtonSegment<CreateWizardTypes>(
                                value: CreateWizardTypes.roomReservation,
                                label: Text("Raumreservierung"),
                                icon: Icon(Icons.meeting_room)),
                            ButtonSegment<CreateWizardTypes>(
                                value: CreateWizardTypes.dayTrip,
                                label: Text("Tagesausflug"),
                                icon: Icon(Icons.short_text)),
                            ButtonSegment<CreateWizardTypes>(
                                value: CreateWizardTypes.longTrip,
                                label: Text("Mehrtagesausflug"),
                                icon: Icon(Icons.calendar_view_week)),
                          ],
                          selected: <CreateWizardTypes>{wizardType},
                          onSelectionChanged: (selected) {
                            setState(() {
                              wizardType = selected.first;
                              switch (wizardType) {
                                case CreateWizardTypes.roomReservation:
                                  appBarTitle = "Neue Raumreservierung";
                                  break;
                                case CreateWizardTypes.dayTrip:
                                  appBarTitle = "Neuer Tagesausflug";
                                  break;
                                case CreateWizardTypes.longTrip:
                                  appBarTitle = "Neuer Mehrtagesausflug";
                                  break;
                              }
                            });
                          },
                        )),
                      )),
                  if (wizardType == CreateWizardTypes.roomReservation) ...[
                    Step(
                        title: const Text('Raum'),
                        content: Card(
                          child: ListTile(
                              title: Form(
                            key: formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: [
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Bitte geben Sie einen Titel ein';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Titel',
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Bitte geben Sie eine Beschreibung ein';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Beschreibung',
                                  ),
                                ),
                              ],
                            ),
                          )),
                        )),
                    Step(
                        title: const Text('Zeit'),
                        content: Card(
                          child: ListTile(title: Text("TMP")),
                        )),
                    Step(
                        title: const Text('Teilnehmer'),
                        content: Card(
                          child: ListTile(title: Text("TMP")),
                        )),
                    Step(
                        title: const Text('Equipment'),
                        content: Card(
                          child: ListTile(title: Text("TMP")),
                        )),
                  ],
                  if (wizardType == CreateWizardTypes.dayTrip) ...[
                    Step(
                        title: const Text('Tagesausflug'),
                        content: Card(
                          child: ListTile(
                              title: Form(
                            key: formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: [
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Bitte geben Sie einen Titel ein';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Titel',
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Bitte geben Sie eine Beschreibung ein';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Beschreibung / Inhalt',
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Bitte geben Sie ein, wozu der Ausflug ergänzend ist';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Ergänzend zu',
                                  ),
                                ),
                              ],
                            ),
                          )),
                        )),
                    Step(
                        title: const Text('Zeit'),
                        content: Card(
                          child: ListTile(
                              title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  const Text("Startdatum:"),
                                  FilledButton(
                                    onPressed: () =>
                                        _selectStartDate(context, true),
                                    child: Text(
                                        "${startDate.day.toString().padLeft(2, '0')}.${startDate.month.toString().padLeft(2, '0')}.${startDate.year}"),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Startzeit:"),
                                  FilledButton(
                                    onPressed: () => _selectStartTime(context),
                                    child: Text(
                                        "${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}"),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Column(
                                children: [
                                  const Text("Enddatum:"),
                                  FilledButton(
                                    onPressed: () =>
                                        _selectEndDate(context, true),
                                    child: Text(
                                        "${endDate.day.toString().padLeft(2, '0')}.${endDate.month.toString().padLeft(2, '0')}.${endDate.year}"),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Endzeit:"),
                                  FilledButton(
                                    onPressed: () => _selectEndTime(context),
                                    child: Text(
                                        "${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}"),
                                  ),
                                ],
                              ),
                            ],
                          )),
                        )),
                    Step(
                        title: const Text('Beteiligte Personen'),
                        content: Card(
                          child: ListTile(
                              title: Column(
                            children: [
                              const Text("Lehrkräfte"),
                              FutureBuilder<Response>(
                                future: ServerApi.getUsers(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Response> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return Text(
                                          'Loaded: ${jsonDecode(snapshot.data!.body.toString())}');
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              const Text("Schüler"),
                              const SizedBox(height: 8),
                              const Text(
                                  "Betroffene Lehrkräfte (Stundenentfall)"),
                              const SizedBox(height: 8),
                              const Text("Verantwortliche Abteilungsvorstände"),
                              const SizedBox(height: 8),
                              const Text("Begleitpersonen"),
                              const SizedBox(height: 8),
                              const Text("Veranstatungsleitung")
                            ],
                          )),
                        )),
                    Step(
                        title: const Text('Kosten'),
                        content: Card(
                          child: ListTile(
                              title: Form(
                            key: costsKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Kosten:"),
                                    const SizedBox(width: 8),
                                    Switch(
                                        value: costs,
                                        onChanged: (value) =>
                                            setState(() => costs = value)),
                                  ],
                                ),
                                if (costs) ...[
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Kosten pro Schüler',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Bitte geben Sie einen Betrag ein';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Bitte geben Sie einen gültigen Betrag ein';
                                      }
                                      if (double.parse(value) < 0) {
                                        return 'Bitte geben Sie einen positiven Betrag ein';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Kosten pro Lehrkraft',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Bitte geben Sie einen Betrag ein';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Bitte geben Sie einen gültigen Betrag ein';
                                      }
                                      if (double.parse(value) < 0) {
                                        return 'Bitte geben Sie einen positiven Betrag ein';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Reisekosten (Fahrtkosten):"),
                                      const SizedBox(width: 8),
                                      Switch(
                                          value: costsTravel,
                                          onChanged: (value) => setState(
                                              () => costsTravel = value)),
                                    ],
                                  ),
                                  if (costsTravel) ...[
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Reisekosten (Fahrtkosten)',
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Bitte geben Sie einen Betrag ein';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Bitte geben Sie einen gültigen Betrag ein';
                                        }
                                        if (double.parse(value) < 0) {
                                          return 'Bitte geben Sie einen positiven Betrag ein';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Reisekosten (Tageskosten):"),
                                      const SizedBox(width: 8),
                                      Switch(
                                          value: costsDaily,
                                          onChanged: (value) => setState(
                                              () => costsDaily = value)),
                                    ],
                                  ),
                                  if (costsDaily) ...[
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Reisekosten (Tageskosten)',
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Bitte geben Sie einen Betrag ein';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Bitte geben Sie einen gültigen Betrag ein';
                                        }
                                        if (double.parse(value) < 0) {
                                          return 'Bitte geben Sie einen positiven Betrag ein';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                          "Buchung über Schule (Buisness Card):"),
                                      const SizedBox(width: 8),
                                      Switch(
                                          value: costsViaBuisnessCard,
                                          onChanged: (value) => setState(() =>
                                              costsViaBuisnessCard = value)),
                                    ],
                                  ),
                                  if (costsViaBuisnessCard) ...[
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText:
                                            'Buchung über Schule (Buisness Card)',
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Bitte geben Sie einen Betrag ein';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Bitte geben Sie einen gültigen Betrag ein';
                                        }
                                        if (double.parse(value) < 0) {
                                          return 'Bitte geben Sie einen positiven Betrag ein';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          )),
                        )),
                  ],
                  if (wizardType == CreateWizardTypes.longTrip) ...[
                    Step(
                        title: const Text('Mehrtagesausflug'),
                        content: Card(
                          child: ListTile(title: Text("TMP")),
                        )),
                    Step(
                        title: const Text('Zeit'),
                        content: Card(
                          child: ListTile(title: Text("TMP")),
                        )),
                    Step(
                        title: const Text('Beteiligte Personen'),
                        content: Card(
                          child: ListTile(title: Text("TMP")),
                        )),
                    Step(
                        title: const Text('Kosten'),
                        content: Card(
                          child: ListTile(title: Text("TMP")),
                        )),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
