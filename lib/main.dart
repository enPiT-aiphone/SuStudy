import 'import.dart';
import 'view_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuStudy Database Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ViewFormSelection(),
    );
  }
}