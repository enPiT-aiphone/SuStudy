import 'package:sustudy_add/presentation/component/problem.dart';

import 'import.dart';
import 'view_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuStudy Database Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FigmaToCodeApp(),
    );
  }
}