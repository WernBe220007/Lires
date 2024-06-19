import 'package:flutter/material.dart';

class CreateWizard extends StatefulWidget {
  const CreateWizard({super.key});

  @override
  State<CreateWizard> createState() => CreateWizardState();
}

enum CreateWizardTypes { roomReservation, dayTrip, longTrip }

class CreateWizardState extends State<CreateWizard> {
  int step = 0;
  String appBarTitle = "Neu";
  CreateWizardTypes wizardType = CreateWizardTypes.dayTrip;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                          child: ListTile(title:  Form(
                            key: formKey,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
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
