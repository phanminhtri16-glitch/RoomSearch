import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/system_report_entity.dart';

class SystemReportModel extends SystemReportEntity {
  SystemReportModel({
    required super.maBaoCao,
    required super.loaiBaoCao,
    required super.tuNgay,
    required super.denNgay,
    required super.soTaiKhoanMoi,
    required super.soTinDangMoi,
    required super.tongYeuCauThue,
    required super.tongGiaoDichDatCoc,
    required super.tongDoanhThuDatCoc,
    required super.ngayTao,
  });

  factory SystemReportModel.fromMap(Map<String, dynamic> map, String id) {
    return SystemReportModel(
      maBaoCao: id,
      loaiBaoCao: map['LoaiBaoCao'] ?? 'THU_CONG',
      tuNgay: map['TuNgay'] is Timestamp
          ? (map['TuNgay'] as Timestamp).toDate()
          : (map['TuNgay'] != null ? DateTime.tryParse(map['TuNgay'].toString()) ?? DateTime.now() : DateTime.now()),
      denNgay: map['DenNgay'] is Timestamp
          ? (map['DenNgay'] as Timestamp).toDate()
          : (map['DenNgay'] != null ? DateTime.tryParse(map['DenNgay'].toString()) ?? DateTime.now() : DateTime.now()),
      soTaiKhoanMoi: map['SoTaiKhoanMoi'] ?? 0,
      soTinDangMoi: map['SoTinDangMoi'] ?? 0,
      tongYeuCauThue: map['TongYeuCauThue'] ?? 0,
      tongGiaoDichDatCoc: map['TongGiaoDichDatCoc'] ?? 0,
      tongDoanhThuDatCoc: (map['TongDoanhThuDatCoc'] ?? 0.0).toDouble(),
      ngayTao: map['NgayTao'] is Timestamp
          ? (map['NgayTao'] as Timestamp).toDate()
          : (map['NgayTao'] != null ? DateTime.tryParse(map['NgayTao'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'LoaiBaoCao': loaiBaoCao,
      'TuNgay': Timestamp.fromDate(tuNgay),
      'DenNgay': Timestamp.fromDate(denNgay),
      'SoTaiKhoanMoi': soTaiKhoanMoi,
      'SoTinDangMoi': soTinDangMoi,
      'TongYeuCauThue': tongYeuCauThue,
      'TongGiaoDichDatCoc': tongGiaoDichDatCoc,
      'TongDoanhThuDatCoc': tongDoanhThuDatCoc,
      'NgayTao': Timestamp.fromDate(ngayTao),
    };
  }
}
