import 'dart:convert';

//necesitamos probar que la clase sellada de fallos
import 'package:gestor_cafeteria/core/failure.dart';

//necesita,ps probar que el cliente http finione 
import 'package:gestor_cafeteria/core/http_client.dart';

//compara los resultados de la peticion con los resultados esperados
import 'package:http/http.dart' as http;

//libreria propia de http para realizar test
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';

//funcion que retorna un objeto de tipo client que responde con un status code y un body determinado, para poder probar el cliente http sin necesidad de hacer peticiones reales
ApiClient clienteQueResponde(int status, [Object? body]) {
  return  ApiClient(
    baseUrl: 'http://localhost:8000', 
    client: MockClient(
      (request) async => http.Response.bytes(
        body == null ? const [] : utf8.encode(jsonEncode(body)),
        status,
        headers: {'Content-Type': 'application/json'},
      )));
}

void main() {
  //hacer el agrupamiento de pruebas
  group('Probar los Codigos de error', () {
    test('404 -> NotFoundFailure()', () async {
      final api = clienteQueResponde(404, {'detail': 'Order 999 not found'});
      await expectLater(
        api.get('/orders/999'),
        throwsA(isA<NotFoundFailure>()),
      );
    }); // test('404 -> NotFoundFailure()')

    test('409 -> ConflictFailure()', () async {
      final api = clienteQueResponde(409, {'detail': 'Conflicto con recurso existente'});
      await expectLater(
        api.post('/recurso-existente', {'data': 'test'}),
        throwsA(isA<ConflictFailure>()),
      );
    }); // test('409 -> ConflictFailure()')

    test('406 -> UnexpectedFailure() (no contemplado explícitamente)', () async {
      final api = clienteQueResponde(406, {'detail': 'No aceptable'});
      await expectLater(
        api.get('/no-aceptable'),
        throwsA(isA<UnexpectedFailure>()),
      );
    }); // test('406 -> UnexpectedFailure() (no contemplado explícitamente)')

    test('410 -> UnexpectedFailure() (no contemplado explícitamente)', () async {
      final api = clienteQueResponde(410, {'detail': 'Recurso ya no disponible'});
      await expectLater(
        api.get('/recurso-eliminado'),
        throwsA(isA<UnexpectedFailure>()),
      );
    }); // test('410 -> UnexpectedFailure() (no contemplado explícitamente)')

    test('422 -> ValidationFailure()', () async {
      final api = clienteQueResponde(422, {
        'detail': [
          {'loc': ['body', 'email'], 'msg': 'Email inválido'},
        ],
      });
      await expectLater(
        api.post('/validacion', {'email': 'invalid-email'}),
        throwsA(isA<ValidationFailure>()),
      );
    }); // test('422 -> ValidationFailure()')

    test('450 -> UnexpectedFailure() (no contemplado explícitamente)', () async {
      final api = clienteQueResponde(450, {'detail': 'Código no aceptado'});
      await expectLater(
        api.get('/codigo-no-aceptado'),
        throwsA(isA<UnexpectedFailure>()),
      );
    }); // test('450 -> UnexpectedFailure() (no contemplado explícitamente)')

    test('500 -> ServerFailure()', () async {
      final api = clienteQueResponde(500, {'detail': 'Error interno'});
      await expectLater(
        api.get('/error-servidor'),
        throwsA(isA<ServerFailure>()),
      );
    }); // test('500 -> ServerFailure()')

    test('503 -> ServerFailure() (dentro del rango 500-599)', () async {
      final api = clienteQueResponde(503, {'detail': 'Servicio no disponible'});
      await expectLater(
        api.get('/servicio-no-disponible'),
        throwsA(isA<ServerFailure>()),
      );
    }); // test('503 -> ServerFailure() (dentro del rango 500-599)')
  }); // group('Probar los Codigos de error')

  group('Probar los límites del rango de éxito (200-300)', () {
    test('200 -> no lanza excepción', () async {
      final api = clienteQueResponde(200, {'message': 'ok'});
      final respuesta = await api.get('/ok');
      expect(respuesta, {'message': 'ok'});
    }); // test('200 -> no lanza excepción')

    test('201 -> no lanza excepción', () async {
      final api = clienteQueResponde(201, {'message': 'creado'});
      final respuesta = await api.post('/creado', {'data': 'test'});
      expect(respuesta, {'message': 'creado'});
    }); // test('201 -> no lanza excepción')

    test('299 -> no lanza excepción', () async {
      final api = clienteQueResponde(299, {'message': 'Al borde del límite'});
      final respuesta = await api.get('/limite');
      expect(respuesta, {'message': 'Al borde del límite'});
    }); // test('299 -> no lanza excepción')

    test('300 -> no lanza excepción (límite superior incluido)', () async {
      final api = clienteQueResponde(300, {'message': 'limite'});
      final respuesta = await api.get('/limite');
      expect(respuesta, {'message': 'limite'});
    }); // test('300 -> no lanza excepción (límite superior incluido)')
  }); // group('Probar los límites del rango de éxito (200-300)')

  group('Probar códigos fuera de todos los rangos contemplados', () {
    test('0 -> UnexpectedFailure() (código inválido/sin respuesta HTTP real)', () {
      // El paquete http no permite crear una respuesta con status code 0,
      // por lo que se valida directamente el mapeo de mapHttpError.
      final api = ApiClient(baseUrl: 'http://localhost:8000');
      final failure = api.mapHttpError(0, {'detail': 'sin conexión'});
      expect(failure, isA<UnexpectedFailure>());
    }); // test('0 -> UnexpectedFailure() (código inválido/sin respuesta HTTP real)')

    test('199 -> UnexpectedFailure() (debajo del rango de éxito)', () async {
      final api = clienteQueResponde(199, {'detail': 'sospechoso'});
      await expectLater(
        api.get('/sospechoso-199'),
        throwsA(isA<UnexpectedFailure>()),
      );
    }); // test('199 -> UnexpectedFailure() (debajo del rango de éxito)')

    test('301 -> UnexpectedFailure() (arriba del rango de éxito)', () async {
      final api = clienteQueResponde(301, {'detail': 'sospechoso'});
      await expectLater(
        api.get('/sospechoso-301'),
        throwsA(isA<UnexpectedFailure>()),
      );
    }); // test('301 -> UnexpectedFailure() (arriba del rango de éxito)')

    test('600 -> UnexpectedFailure() (arriba del rango de servidor)', () async {
      final api = clienteQueResponde(600, {'detail': 'desconocido'});
      await expectLater(
        api.get('/sospechoso-600'),
        throwsA(isA<UnexpectedFailure>()),
      );
    }); // test('600 -> UnexpectedFailure() (arriba del rango de servidor)')

    test('601 -> UnexpectedFailure() (arriba del rango de servidor)', () async {
      final api = clienteQueResponde(601, {'detail': 'desconocido'});
      await expectLater(
        api.get('/sospechoso-601'),
        throwsA(isA<UnexpectedFailure>()),
      );
    }); // test('601 -> UnexpectedFailure() (arriba del rango de servidor)')
  }); // group('Probar códigos fuera de todos los rangos contemplados')
} // main()