import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class FakeQueryDocumentSnapshot {
  final Map<String, dynamic> _data;
  FakeQueryDocumentSnapshot(this._data);

  dynamic get(String key) => _data[key];
}

class FakeQuerySnapshot {
  final List<FakeQueryDocumentSnapshot> docs;
  FakeQuerySnapshot(this.docs);
}

class FakeCollectionReference {
  final List<Map<String, dynamic>> _documents;

  FakeCollectionReference(this._documents);

  Future<FakeQuerySnapshot> where(String field,
      {required dynamic isEqualTo}) async {
    final filtered = _documents
        .where((doc) => doc[field] == isEqualTo)
        .map((doc) => FakeQueryDocumentSnapshot(doc))
        .toList();
    return FakeQuerySnapshot(filtered);
  }
}

class FakeFirestore {
  final Map<String, List<Map<String, dynamic>>> _collections;

  FakeFirestore(this._collections);

  FakeCollectionReference collection(String name) {
    return FakeCollectionReference(_collections[name] ?? []);
  }
}

void main() {
  group('Inicio De Sesión', () {
    final mockUser = MockUser(
      uid: 'abc123',
      email: 'usuario@test.com',
    );

    final mockAuth = MockFirebaseAuth(mockUser: mockUser);

    late FakeFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirestore({
        'usuarios': [
          {'dni': '12345678', 'email': 'usuario@test.com'},
        ],
        'empleados': [],
      });
    });

    test('Login Exitoso Con Credenciales Cálidas', () async {
      final query = await fakeFirestore
          .collection('usuarios')
          .where('dni', isEqualTo: '12345678');

      expect(query.docs.isNotEmpty, true);

      final email = query.docs.first.get('email');

      expect(email, 'usuario@test.com');

      final userCredential = await mockAuth.signInWithEmailAndPassword(
        email: email,
        password: '123456',
      );

      expect(userCredential.user, isNotNull);
      expect(userCredential.user!.email, 'usuario@test.com');
    });

    test('No Se Encuentra El DNI', () async {
      final query = await fakeFirestore
          .collection('usuarios')
          .where('dni', isEqualTo: '99999999');
      expect(query.docs.isEmpty, true);
    });
  });
}
