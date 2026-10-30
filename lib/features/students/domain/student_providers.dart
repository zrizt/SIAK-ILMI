import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../data/student_repository.dart';

part 'student_providers.g.dart';

class StudentFilter {
  const StudentFilter({this.sekolahId, this.searchQuery = ''});
  final int? sekolahId;
  final String searchQuery;

  StudentFilter copyWith({
    int? sekolahId,
    String? searchQuery,
    bool clearSekolah = false,
  }) =>
      StudentFilter(
        sekolahId: clearSekolah ? null : (sekolahId ?? this.sekolahId),
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

final studentFilterProvider = StateProvider<StudentFilter>(
  (ref) => const StudentFilter(),
);

@riverpod
Stream<List<SiswaData>> filteredStudentList(Ref ref) {
  final filter = ref.watch(studentFilterProvider);
  final repo = ref.watch(studentRepositoryProvider);
  return repo.watchActive(sekolahId: filter.sekolahId).map((list) {
    if (filter.searchQuery.isEmpty) return list;
    final q = filter.searchQuery.toLowerCase();
    return list
        .where(
          (s) =>
              s.namaLengkap.toLowerCase().contains(q) ||
              s.nis.contains(q) ||
              (s.nisn?.contains(q) ?? false),
        )
        .toList();
  });
}

@riverpod
Future<SiswaData?> studentDetail(Ref ref, int id) {
  return ref.watch(studentRepositoryProvider).getById(id);
}
