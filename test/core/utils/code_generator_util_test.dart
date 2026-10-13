import 'package:flutter_test/flutter_test.dart';
import 'package:room_search/core/utils/code_generator_util.dart';

void main() {
  group('CodeGeneratorUtil Rule-Based Room Code Tests', () {
    test('generateRoomCode generates structured prefix based on district', () {
      final codeCG = CodeGeneratorUtil.generateRoomCode(district: 'Cầu Giấy, Hà Nội', customSeq: 1);
      expect(codeCG, startsWith('P-CG-'));
      expect(codeCG, endsWith('-001'));

      final codeQ7 = CodeGeneratorUtil.generateRoomCode(district: 'Quận 7, TP.HCM', customSeq: 2);
      expect(codeQ7, startsWith('P-Q7-'));
      expect(codeQ7, endsWith('-002'));

      final codeTD = CodeGeneratorUtil.generateRoomCode(district: 'Thủ Đức, TP.HCM', customSeq: 3);
      expect(codeTD, startsWith('P-TD-'));
      expect(codeTD, endsWith('-003'));

      final codeDefault = CodeGeneratorUtil.generateRoomCode(district: '', customSeq: 4);
      expect(codeDefault, startsWith('P-PT-'));
      expect(codeDefault, endsWith('-004'));
    });

    test('getDistrictPrefix maps district names accurately', () {
      expect(CodeGeneratorUtil.getDistrictPrefix('Đống Đa, Hà Nội'), equals('DD'));
      expect(CodeGeneratorUtil.getDistrictPrefix('Bình Thạnh, TP.HCM'), equals('BTH'));
      expect(CodeGeneratorUtil.getDistrictPrefix('Gò Vấp, TP.HCM'), equals('GV'));
      expect(CodeGeneratorUtil.getDistrictPrefix('Ba Đình, Hà Nội'), equals('BD'));
    });

    test('Rule-based code generators produce sequential structured prefixes', () {
      final msgCode = CodeGeneratorUtil.generateMessageCode();
      expect(msgCode, startsWith('TN-'));
      expect(msgCode, endsWith('-001'));

      final reqCode = CodeGeneratorUtil.generateRequestCode();
      expect(reqCode, startsWith('YC-'));
      expect(reqCode, endsWith('-001'));

      final contractCode = CodeGeneratorUtil.generateContractCode();
      expect(contractCode, startsWith('HD-'));
      expect(contractCode, endsWith('-001'));

      final txnCode = CodeGeneratorUtil.generateTransactionCode();
      expect(txnCode, startsWith('TXN-'));
      expect(txnCode, endsWith('-001'));

      final notifCode = CodeGeneratorUtil.generateNotificationCode();
      expect(notifCode, startsWith('TB-'));
      expect(notifCode, endsWith('-001'));

      final reviewCode = CodeGeneratorUtil.generateReviewCode();
      expect(reviewCode, startsWith('DG-'));
      expect(reviewCode, endsWith('-001'));

      final studentCode = CodeGeneratorUtil.generateStudentCode();
      expect(studentCode, startsWith('SV-'));
      expect(studentCode, endsWith('-001'));

      final landlordCode = CodeGeneratorUtil.generateLandlordCode();
      expect(landlordCode, startsWith('CT-'));
      expect(landlordCode, endsWith('-001'));

      final adminCode = CodeGeneratorUtil.generateAdminCode();
      expect(adminCode, startsWith('AD-'));
      expect(adminCode, endsWith('-001'));

      final reportCode = CodeGeneratorUtil.generateReportCode();
      expect(reportCode, startsWith('BC-'));
      expect(reportCode, endsWith('-001'));
    });

    test('formatRoomDisplayCode formats raw Firestore room IDs into rule-based room codes', () {
      final formatted = CodeGeneratorUtil.formatRoomDisplayCode('1CQJugggp8fkEPPnUsC');
      expect(formatted, startsWith('P-PT-'));

      final alreadyRuleBased = CodeGeneratorUtil.formatRoomDisplayCode('P-CG-20260808-001');
      expect(alreadyRuleBased, equals('P-CG-20260808-001'));
    });

    test('formatStudentDisplayCode and formatContractDisplayCode format raw UIDs into rule-based strings', () {
      final formattedStudent = CodeGeneratorUtil.formatStudentDisplayCode('NjdS5rlfaberKPoQ9xql');
      expect(formattedStudent, startsWith('Sinh viên '));

      final formattedContract = CodeGeneratorUtil.formatContractDisplayCode('HD_178590615276');
      expect(formattedContract, startsWith('HD-'));
    });
  });
}
