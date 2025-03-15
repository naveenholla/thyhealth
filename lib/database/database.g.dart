// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PatientsTable extends Patients with TableInfo<$PatientsTable, Patient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Patient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Patient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Patient(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class Patient extends DataClass implements Insertable<Patient> {
  final int id;
  final String name;
  final DateTime createdAt;
  const Patient({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Patient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Patient(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Patient copyWith({int? id, String? name, DateTime? createdAt}) => Patient(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  Patient copyWithCompanion(PatientsCompanion data) {
    return Patient(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Patient(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Patient &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PatientsCompanion extends UpdateCompanion<Patient> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PatientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Patient> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PatientsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return PatientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MedicalReportsTable extends MedicalReports
    with TableInfo<$MedicalReportsTable, MedicalReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicalReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<int> patientId = GeneratedColumn<int>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _reportDateMeta = const VerificationMeta(
    'reportDate',
  );
  @override
  late final GeneratedColumn<String> reportDate = GeneratedColumn<String>(
    'report_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadedAtMeta = const VerificationMeta(
    'uploadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> uploadedAt = GeneratedColumn<DateTime>(
    'uploaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _originalFilePathMeta = const VerificationMeta(
    'originalFilePath',
  );
  @override
  late final GeneratedColumn<String> originalFilePath = GeneratedColumn<String>(
    'original_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    reportDate,
    uploadedAt,
    originalFilePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medical_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicalReport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('report_date')) {
      context.handle(
        _reportDateMeta,
        reportDate.isAcceptableOrUnknown(data['report_date']!, _reportDateMeta),
      );
    } else if (isInserting) {
      context.missing(_reportDateMeta);
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
        _uploadedAtMeta,
        uploadedAt.isAcceptableOrUnknown(data['uploaded_at']!, _uploadedAtMeta),
      );
    }
    if (data.containsKey('original_file_path')) {
      context.handle(
        _originalFilePathMeta,
        originalFilePath.isAcceptableOrUnknown(
          data['original_file_path']!,
          _originalFilePathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicalReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicalReport(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      patientId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}patient_id'],
          )!,
      reportDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}report_date'],
          )!,
      uploadedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}uploaded_at'],
          )!,
      originalFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_file_path'],
      ),
    );
  }

  @override
  $MedicalReportsTable createAlias(String alias) {
    return $MedicalReportsTable(attachedDatabase, alias);
  }
}

class MedicalReport extends DataClass implements Insertable<MedicalReport> {
  final int id;
  final int patientId;
  final String reportDate;
  final DateTime uploadedAt;
  final String? originalFilePath;
  const MedicalReport({
    required this.id,
    required this.patientId,
    required this.reportDate,
    required this.uploadedAt,
    this.originalFilePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['patient_id'] = Variable<int>(patientId);
    map['report_date'] = Variable<String>(reportDate);
    map['uploaded_at'] = Variable<DateTime>(uploadedAt);
    if (!nullToAbsent || originalFilePath != null) {
      map['original_file_path'] = Variable<String>(originalFilePath);
    }
    return map;
  }

  MedicalReportsCompanion toCompanion(bool nullToAbsent) {
    return MedicalReportsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      reportDate: Value(reportDate),
      uploadedAt: Value(uploadedAt),
      originalFilePath:
          originalFilePath == null && nullToAbsent
              ? const Value.absent()
              : Value(originalFilePath),
    );
  }

  factory MedicalReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicalReport(
      id: serializer.fromJson<int>(json['id']),
      patientId: serializer.fromJson<int>(json['patientId']),
      reportDate: serializer.fromJson<String>(json['reportDate']),
      uploadedAt: serializer.fromJson<DateTime>(json['uploadedAt']),
      originalFilePath: serializer.fromJson<String?>(json['originalFilePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'patientId': serializer.toJson<int>(patientId),
      'reportDate': serializer.toJson<String>(reportDate),
      'uploadedAt': serializer.toJson<DateTime>(uploadedAt),
      'originalFilePath': serializer.toJson<String?>(originalFilePath),
    };
  }

  MedicalReport copyWith({
    int? id,
    int? patientId,
    String? reportDate,
    DateTime? uploadedAt,
    Value<String?> originalFilePath = const Value.absent(),
  }) => MedicalReport(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    reportDate: reportDate ?? this.reportDate,
    uploadedAt: uploadedAt ?? this.uploadedAt,
    originalFilePath:
        originalFilePath.present
            ? originalFilePath.value
            : this.originalFilePath,
  );
  MedicalReport copyWithCompanion(MedicalReportsCompanion data) {
    return MedicalReport(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      reportDate:
          data.reportDate.present ? data.reportDate.value : this.reportDate,
      uploadedAt:
          data.uploadedAt.present ? data.uploadedAt.value : this.uploadedAt,
      originalFilePath:
          data.originalFilePath.present
              ? data.originalFilePath.value
              : this.originalFilePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicalReport(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('reportDate: $reportDate, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('originalFilePath: $originalFilePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, patientId, reportDate, uploadedAt, originalFilePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicalReport &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.reportDate == this.reportDate &&
          other.uploadedAt == this.uploadedAt &&
          other.originalFilePath == this.originalFilePath);
}

class MedicalReportsCompanion extends UpdateCompanion<MedicalReport> {
  final Value<int> id;
  final Value<int> patientId;
  final Value<String> reportDate;
  final Value<DateTime> uploadedAt;
  final Value<String?> originalFilePath;
  const MedicalReportsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.reportDate = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.originalFilePath = const Value.absent(),
  });
  MedicalReportsCompanion.insert({
    this.id = const Value.absent(),
    required int patientId,
    required String reportDate,
    this.uploadedAt = const Value.absent(),
    this.originalFilePath = const Value.absent(),
  }) : patientId = Value(patientId),
       reportDate = Value(reportDate);
  static Insertable<MedicalReport> custom({
    Expression<int>? id,
    Expression<int>? patientId,
    Expression<String>? reportDate,
    Expression<DateTime>? uploadedAt,
    Expression<String>? originalFilePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (reportDate != null) 'report_date': reportDate,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
      if (originalFilePath != null) 'original_file_path': originalFilePath,
    });
  }

  MedicalReportsCompanion copyWith({
    Value<int>? id,
    Value<int>? patientId,
    Value<String>? reportDate,
    Value<DateTime>? uploadedAt,
    Value<String?>? originalFilePath,
  }) {
    return MedicalReportsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      reportDate: reportDate ?? this.reportDate,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      originalFilePath: originalFilePath ?? this.originalFilePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<int>(patientId.value);
    }
    if (reportDate.present) {
      map['report_date'] = Variable<String>(reportDate.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt.value);
    }
    if (originalFilePath.present) {
      map['original_file_path'] = Variable<String>(originalFilePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicalReportsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('reportDate: $reportDate, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('originalFilePath: $originalFilePath')
          ..write(')'))
        .toString();
  }
}

class $TestResultsTable extends TestResults
    with TableInfo<$TestResultsTable, TestResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _reportIdMeta = const VerificationMeta(
    'reportId',
  );
  @override
  late final GeneratedColumn<int> reportId = GeneratedColumn<int>(
    'report_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medical_reports (id)',
    ),
  );
  static const VerificationMeta _testNameMeta = const VerificationMeta(
    'testName',
  );
  @override
  late final GeneratedColumn<String> testName = GeneratedColumn<String>(
    'test_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceRangeMeta = const VerificationMeta(
    'referenceRange',
  );
  @override
  late final GeneratedColumn<String> referenceRange = GeneratedColumn<String>(
    'reference_range',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foodSuggestionsMeta = const VerificationMeta(
    'foodSuggestions',
  );
  @override
  late final GeneratedColumn<String> foodSuggestions = GeneratedColumn<String>(
    'food_suggestions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAbnormalMeta = const VerificationMeta(
    'isAbnormal',
  );
  @override
  late final GeneratedColumn<bool> isAbnormal = GeneratedColumn<bool>(
    'is_abnormal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_abnormal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reportId,
    testName,
    result,
    referenceRange,
    foodSuggestions,
    isAbnormal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('report_id')) {
      context.handle(
        _reportIdMeta,
        reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reportIdMeta);
    }
    if (data.containsKey('test_name')) {
      context.handle(
        _testNameMeta,
        testName.isAcceptableOrUnknown(data['test_name']!, _testNameMeta),
      );
    } else if (isInserting) {
      context.missing(_testNameMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('reference_range')) {
      context.handle(
        _referenceRangeMeta,
        referenceRange.isAcceptableOrUnknown(
          data['reference_range']!,
          _referenceRangeMeta,
        ),
      );
    }
    if (data.containsKey('food_suggestions')) {
      context.handle(
        _foodSuggestionsMeta,
        foodSuggestions.isAcceptableOrUnknown(
          data['food_suggestions']!,
          _foodSuggestionsMeta,
        ),
      );
    }
    if (data.containsKey('is_abnormal')) {
      context.handle(
        _isAbnormalMeta,
        isAbnormal.isAcceptableOrUnknown(data['is_abnormal']!, _isAbnormalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestResult(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      reportId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}report_id'],
          )!,
      testName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}test_name'],
          )!,
      result:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}result'],
          )!,
      referenceRange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_range'],
      ),
      foodSuggestions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_suggestions'],
      ),
      isAbnormal:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_abnormal'],
          )!,
    );
  }

  @override
  $TestResultsTable createAlias(String alias) {
    return $TestResultsTable(attachedDatabase, alias);
  }
}

class TestResult extends DataClass implements Insertable<TestResult> {
  final int id;
  final int reportId;
  final String testName;
  final String result;
  final String? referenceRange;
  final String? foodSuggestions;
  final bool isAbnormal;
  const TestResult({
    required this.id,
    required this.reportId,
    required this.testName,
    required this.result,
    this.referenceRange,
    this.foodSuggestions,
    required this.isAbnormal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['report_id'] = Variable<int>(reportId);
    map['test_name'] = Variable<String>(testName);
    map['result'] = Variable<String>(result);
    if (!nullToAbsent || referenceRange != null) {
      map['reference_range'] = Variable<String>(referenceRange);
    }
    if (!nullToAbsent || foodSuggestions != null) {
      map['food_suggestions'] = Variable<String>(foodSuggestions);
    }
    map['is_abnormal'] = Variable<bool>(isAbnormal);
    return map;
  }

  TestResultsCompanion toCompanion(bool nullToAbsent) {
    return TestResultsCompanion(
      id: Value(id),
      reportId: Value(reportId),
      testName: Value(testName),
      result: Value(result),
      referenceRange:
          referenceRange == null && nullToAbsent
              ? const Value.absent()
              : Value(referenceRange),
      foodSuggestions:
          foodSuggestions == null && nullToAbsent
              ? const Value.absent()
              : Value(foodSuggestions),
      isAbnormal: Value(isAbnormal),
    );
  }

  factory TestResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestResult(
      id: serializer.fromJson<int>(json['id']),
      reportId: serializer.fromJson<int>(json['reportId']),
      testName: serializer.fromJson<String>(json['testName']),
      result: serializer.fromJson<String>(json['result']),
      referenceRange: serializer.fromJson<String?>(json['referenceRange']),
      foodSuggestions: serializer.fromJson<String?>(json['foodSuggestions']),
      isAbnormal: serializer.fromJson<bool>(json['isAbnormal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reportId': serializer.toJson<int>(reportId),
      'testName': serializer.toJson<String>(testName),
      'result': serializer.toJson<String>(result),
      'referenceRange': serializer.toJson<String?>(referenceRange),
      'foodSuggestions': serializer.toJson<String?>(foodSuggestions),
      'isAbnormal': serializer.toJson<bool>(isAbnormal),
    };
  }

  TestResult copyWith({
    int? id,
    int? reportId,
    String? testName,
    String? result,
    Value<String?> referenceRange = const Value.absent(),
    Value<String?> foodSuggestions = const Value.absent(),
    bool? isAbnormal,
  }) => TestResult(
    id: id ?? this.id,
    reportId: reportId ?? this.reportId,
    testName: testName ?? this.testName,
    result: result ?? this.result,
    referenceRange:
        referenceRange.present ? referenceRange.value : this.referenceRange,
    foodSuggestions:
        foodSuggestions.present ? foodSuggestions.value : this.foodSuggestions,
    isAbnormal: isAbnormal ?? this.isAbnormal,
  );
  TestResult copyWithCompanion(TestResultsCompanion data) {
    return TestResult(
      id: data.id.present ? data.id.value : this.id,
      reportId: data.reportId.present ? data.reportId.value : this.reportId,
      testName: data.testName.present ? data.testName.value : this.testName,
      result: data.result.present ? data.result.value : this.result,
      referenceRange:
          data.referenceRange.present
              ? data.referenceRange.value
              : this.referenceRange,
      foodSuggestions:
          data.foodSuggestions.present
              ? data.foodSuggestions.value
              : this.foodSuggestions,
      isAbnormal:
          data.isAbnormal.present ? data.isAbnormal.value : this.isAbnormal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestResult(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('testName: $testName, ')
          ..write('result: $result, ')
          ..write('referenceRange: $referenceRange, ')
          ..write('foodSuggestions: $foodSuggestions, ')
          ..write('isAbnormal: $isAbnormal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    reportId,
    testName,
    result,
    referenceRange,
    foodSuggestions,
    isAbnormal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestResult &&
          other.id == this.id &&
          other.reportId == this.reportId &&
          other.testName == this.testName &&
          other.result == this.result &&
          other.referenceRange == this.referenceRange &&
          other.foodSuggestions == this.foodSuggestions &&
          other.isAbnormal == this.isAbnormal);
}

class TestResultsCompanion extends UpdateCompanion<TestResult> {
  final Value<int> id;
  final Value<int> reportId;
  final Value<String> testName;
  final Value<String> result;
  final Value<String?> referenceRange;
  final Value<String?> foodSuggestions;
  final Value<bool> isAbnormal;
  const TestResultsCompanion({
    this.id = const Value.absent(),
    this.reportId = const Value.absent(),
    this.testName = const Value.absent(),
    this.result = const Value.absent(),
    this.referenceRange = const Value.absent(),
    this.foodSuggestions = const Value.absent(),
    this.isAbnormal = const Value.absent(),
  });
  TestResultsCompanion.insert({
    this.id = const Value.absent(),
    required int reportId,
    required String testName,
    required String result,
    this.referenceRange = const Value.absent(),
    this.foodSuggestions = const Value.absent(),
    this.isAbnormal = const Value.absent(),
  }) : reportId = Value(reportId),
       testName = Value(testName),
       result = Value(result);
  static Insertable<TestResult> custom({
    Expression<int>? id,
    Expression<int>? reportId,
    Expression<String>? testName,
    Expression<String>? result,
    Expression<String>? referenceRange,
    Expression<String>? foodSuggestions,
    Expression<bool>? isAbnormal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      if (testName != null) 'test_name': testName,
      if (result != null) 'result': result,
      if (referenceRange != null) 'reference_range': referenceRange,
      if (foodSuggestions != null) 'food_suggestions': foodSuggestions,
      if (isAbnormal != null) 'is_abnormal': isAbnormal,
    });
  }

  TestResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? reportId,
    Value<String>? testName,
    Value<String>? result,
    Value<String?>? referenceRange,
    Value<String?>? foodSuggestions,
    Value<bool>? isAbnormal,
  }) {
    return TestResultsCompanion(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      testName: testName ?? this.testName,
      result: result ?? this.result,
      referenceRange: referenceRange ?? this.referenceRange,
      foodSuggestions: foodSuggestions ?? this.foodSuggestions,
      isAbnormal: isAbnormal ?? this.isAbnormal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reportId.present) {
      map['report_id'] = Variable<int>(reportId.value);
    }
    if (testName.present) {
      map['test_name'] = Variable<String>(testName.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (referenceRange.present) {
      map['reference_range'] = Variable<String>(referenceRange.value);
    }
    if (foodSuggestions.present) {
      map['food_suggestions'] = Variable<String>(foodSuggestions.value);
    }
    if (isAbnormal.present) {
      map['is_abnormal'] = Variable<bool>(isAbnormal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestResultsCompanion(')
          ..write('id: $id, ')
          ..write('reportId: $reportId, ')
          ..write('testName: $testName, ')
          ..write('result: $result, ')
          ..write('referenceRange: $referenceRange, ')
          ..write('foodSuggestions: $foodSuggestions, ')
          ..write('isAbnormal: $isAbnormal')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $MedicalReportsTable medicalReports = $MedicalReportsTable(this);
  late final $TestResultsTable testResults = $TestResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    patients,
    medicalReports,
    testResults,
  ];
}

typedef $$PatientsTableCreateCompanionBuilder =
    PatientsCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
    });
typedef $$PatientsTableUpdateCompanionBuilder =
    PatientsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
    });

final class $$PatientsTableReferences
    extends BaseReferences<_$AppDatabase, $PatientsTable, Patient> {
  $$PatientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MedicalReportsTable, List<MedicalReport>>
  _medicalReportsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicalReports,
    aliasName: $_aliasNameGenerator(
      db.patients.id,
      db.medicalReports.patientId,
    ),
  );

  $$MedicalReportsTableProcessedTableManager get medicalReportsRefs {
    final manager = $$MedicalReportsTableTableManager(
      $_db,
      $_db.medicalReports,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicalReportsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> medicalReportsRefs(
    Expression<bool> Function($$MedicalReportsTableFilterComposer f) f,
  ) {
    final $$MedicalReportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicalReports,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicalReportsTableFilterComposer(
            $db: $db,
            $table: $db.medicalReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> medicalReportsRefs<T extends Object>(
    Expression<T> Function($$MedicalReportsTableAnnotationComposer a) f,
  ) {
    final $$MedicalReportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicalReports,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicalReportsTableAnnotationComposer(
            $db: $db,
            $table: $db.medicalReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTable,
          Patient,
          $$PatientsTableFilterComposer,
          $$PatientsTableOrderingComposer,
          $$PatientsTableAnnotationComposer,
          $$PatientsTableCreateCompanionBuilder,
          $$PatientsTableUpdateCompanionBuilder,
          (Patient, $$PatientsTableReferences),
          Patient,
          PrefetchHooks Function({bool medicalReportsRefs})
        > {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PatientsCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => PatientsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PatientsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({medicalReportsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (medicalReportsRefs) db.medicalReports,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (medicalReportsRefs)
                    await $_getPrefetchedData<
                      Patient,
                      $PatientsTable,
                      MedicalReport
                    >(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._medicalReportsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).medicalReportsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.patientId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PatientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTable,
      Patient,
      $$PatientsTableFilterComposer,
      $$PatientsTableOrderingComposer,
      $$PatientsTableAnnotationComposer,
      $$PatientsTableCreateCompanionBuilder,
      $$PatientsTableUpdateCompanionBuilder,
      (Patient, $$PatientsTableReferences),
      Patient,
      PrefetchHooks Function({bool medicalReportsRefs})
    >;
typedef $$MedicalReportsTableCreateCompanionBuilder =
    MedicalReportsCompanion Function({
      Value<int> id,
      required int patientId,
      required String reportDate,
      Value<DateTime> uploadedAt,
      Value<String?> originalFilePath,
    });
typedef $$MedicalReportsTableUpdateCompanionBuilder =
    MedicalReportsCompanion Function({
      Value<int> id,
      Value<int> patientId,
      Value<String> reportDate,
      Value<DateTime> uploadedAt,
      Value<String?> originalFilePath,
    });

final class $$MedicalReportsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicalReportsTable, MedicalReport> {
  $$MedicalReportsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias(
        $_aliasNameGenerator(db.medicalReports.patientId, db.patients.id),
      );

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<int>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TestResultsTable, List<TestResult>>
  _testResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.testResults,
    aliasName: $_aliasNameGenerator(
      db.medicalReports.id,
      db.testResults.reportId,
    ),
  );

  $$TestResultsTableProcessedTableManager get testResultsRefs {
    final manager = $$TestResultsTableTableManager(
      $_db,
      $_db.testResults,
    ).filter((f) => f.reportId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_testResultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicalReportsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicalReportsTable> {
  $$MedicalReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get uploadedAt => $composableBuilder(
    column: $table.uploadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalFilePath => $composableBuilder(
    column: $table.originalFilePath,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> testResultsRefs(
    Expression<bool> Function($$TestResultsTableFilterComposer f) f,
  ) {
    final $$TestResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testResults,
      getReferencedColumn: (t) => t.reportId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestResultsTableFilterComposer(
            $db: $db,
            $table: $db.testResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicalReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicalReportsTable> {
  $$MedicalReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get uploadedAt => $composableBuilder(
    column: $table.uploadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalFilePath => $composableBuilder(
    column: $table.originalFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicalReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicalReportsTable> {
  $$MedicalReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get uploadedAt => $composableBuilder(
    column: $table.uploadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalFilePath => $composableBuilder(
    column: $table.originalFilePath,
    builder: (column) => column,
  );

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> testResultsRefs<T extends Object>(
    Expression<T> Function($$TestResultsTableAnnotationComposer a) f,
  ) {
    final $$TestResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testResults,
      getReferencedColumn: (t) => t.reportId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.testResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicalReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicalReportsTable,
          MedicalReport,
          $$MedicalReportsTableFilterComposer,
          $$MedicalReportsTableOrderingComposer,
          $$MedicalReportsTableAnnotationComposer,
          $$MedicalReportsTableCreateCompanionBuilder,
          $$MedicalReportsTableUpdateCompanionBuilder,
          (MedicalReport, $$MedicalReportsTableReferences),
          MedicalReport,
          PrefetchHooks Function({bool patientId, bool testResultsRefs})
        > {
  $$MedicalReportsTableTableManager(
    _$AppDatabase db,
    $MedicalReportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MedicalReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$MedicalReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MedicalReportsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> patientId = const Value.absent(),
                Value<String> reportDate = const Value.absent(),
                Value<DateTime> uploadedAt = const Value.absent(),
                Value<String?> originalFilePath = const Value.absent(),
              }) => MedicalReportsCompanion(
                id: id,
                patientId: patientId,
                reportDate: reportDate,
                uploadedAt: uploadedAt,
                originalFilePath: originalFilePath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int patientId,
                required String reportDate,
                Value<DateTime> uploadedAt = const Value.absent(),
                Value<String?> originalFilePath = const Value.absent(),
              }) => MedicalReportsCompanion.insert(
                id: id,
                patientId: patientId,
                reportDate: reportDate,
                uploadedAt: uploadedAt,
                originalFilePath: originalFilePath,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$MedicalReportsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            patientId = false,
            testResultsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (testResultsRefs) db.testResults],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (patientId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.patientId,
                            referencedTable: $$MedicalReportsTableReferences
                                ._patientIdTable(db),
                            referencedColumn:
                                $$MedicalReportsTableReferences
                                    ._patientIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (testResultsRefs)
                    await $_getPrefetchedData<
                      MedicalReport,
                      $MedicalReportsTable,
                      TestResult
                    >(
                      currentTable: table,
                      referencedTable: $$MedicalReportsTableReferences
                          ._testResultsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$MedicalReportsTableReferences(
                                db,
                                table,
                                p0,
                              ).testResultsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.reportId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MedicalReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicalReportsTable,
      MedicalReport,
      $$MedicalReportsTableFilterComposer,
      $$MedicalReportsTableOrderingComposer,
      $$MedicalReportsTableAnnotationComposer,
      $$MedicalReportsTableCreateCompanionBuilder,
      $$MedicalReportsTableUpdateCompanionBuilder,
      (MedicalReport, $$MedicalReportsTableReferences),
      MedicalReport,
      PrefetchHooks Function({bool patientId, bool testResultsRefs})
    >;
typedef $$TestResultsTableCreateCompanionBuilder =
    TestResultsCompanion Function({
      Value<int> id,
      required int reportId,
      required String testName,
      required String result,
      Value<String?> referenceRange,
      Value<String?> foodSuggestions,
      Value<bool> isAbnormal,
    });
typedef $$TestResultsTableUpdateCompanionBuilder =
    TestResultsCompanion Function({
      Value<int> id,
      Value<int> reportId,
      Value<String> testName,
      Value<String> result,
      Value<String?> referenceRange,
      Value<String?> foodSuggestions,
      Value<bool> isAbnormal,
    });

final class $$TestResultsTableReferences
    extends BaseReferences<_$AppDatabase, $TestResultsTable, TestResult> {
  $$TestResultsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicalReportsTable _reportIdTable(_$AppDatabase db) =>
      db.medicalReports.createAlias(
        $_aliasNameGenerator(db.testResults.reportId, db.medicalReports.id),
      );

  $$MedicalReportsTableProcessedTableManager get reportId {
    final $_column = $_itemColumn<int>('report_id')!;

    final manager = $$MedicalReportsTableTableManager(
      $_db,
      $_db.medicalReports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TestResultsTableFilterComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testName => $composableBuilder(
    column: $table.testName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceRange => $composableBuilder(
    column: $table.referenceRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodSuggestions => $composableBuilder(
    column: $table.foodSuggestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAbnormal => $composableBuilder(
    column: $table.isAbnormal,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicalReportsTableFilterComposer get reportId {
    final $$MedicalReportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportId,
      referencedTable: $db.medicalReports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicalReportsTableFilterComposer(
            $db: $db,
            $table: $db.medicalReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testName => $composableBuilder(
    column: $table.testName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceRange => $composableBuilder(
    column: $table.referenceRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodSuggestions => $composableBuilder(
    column: $table.foodSuggestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAbnormal => $composableBuilder(
    column: $table.isAbnormal,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicalReportsTableOrderingComposer get reportId {
    final $$MedicalReportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportId,
      referencedTable: $db.medicalReports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicalReportsTableOrderingComposer(
            $db: $db,
            $table: $db.medicalReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get testName =>
      $composableBuilder(column: $table.testName, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get referenceRange => $composableBuilder(
    column: $table.referenceRange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foodSuggestions => $composableBuilder(
    column: $table.foodSuggestions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAbnormal => $composableBuilder(
    column: $table.isAbnormal,
    builder: (column) => column,
  );

  $$MedicalReportsTableAnnotationComposer get reportId {
    final $$MedicalReportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportId,
      referencedTable: $db.medicalReports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicalReportsTableAnnotationComposer(
            $db: $db,
            $table: $db.medicalReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestResultsTable,
          TestResult,
          $$TestResultsTableFilterComposer,
          $$TestResultsTableOrderingComposer,
          $$TestResultsTableAnnotationComposer,
          $$TestResultsTableCreateCompanionBuilder,
          $$TestResultsTableUpdateCompanionBuilder,
          (TestResult, $$TestResultsTableReferences),
          TestResult,
          PrefetchHooks Function({bool reportId})
        > {
  $$TestResultsTableTableManager(_$AppDatabase db, $TestResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TestResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TestResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$TestResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> reportId = const Value.absent(),
                Value<String> testName = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<String?> referenceRange = const Value.absent(),
                Value<String?> foodSuggestions = const Value.absent(),
                Value<bool> isAbnormal = const Value.absent(),
              }) => TestResultsCompanion(
                id: id,
                reportId: reportId,
                testName: testName,
                result: result,
                referenceRange: referenceRange,
                foodSuggestions: foodSuggestions,
                isAbnormal: isAbnormal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int reportId,
                required String testName,
                required String result,
                Value<String?> referenceRange = const Value.absent(),
                Value<String?> foodSuggestions = const Value.absent(),
                Value<bool> isAbnormal = const Value.absent(),
              }) => TestResultsCompanion.insert(
                id: id,
                reportId: reportId,
                testName: testName,
                result: result,
                referenceRange: referenceRange,
                foodSuggestions: foodSuggestions,
                isAbnormal: isAbnormal,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$TestResultsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({reportId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (reportId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.reportId,
                            referencedTable: $$TestResultsTableReferences
                                ._reportIdTable(db),
                            referencedColumn:
                                $$TestResultsTableReferences
                                    ._reportIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TestResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestResultsTable,
      TestResult,
      $$TestResultsTableFilterComposer,
      $$TestResultsTableOrderingComposer,
      $$TestResultsTableAnnotationComposer,
      $$TestResultsTableCreateCompanionBuilder,
      $$TestResultsTableUpdateCompanionBuilder,
      (TestResult, $$TestResultsTableReferences),
      TestResult,
      PrefetchHooks Function({bool reportId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$MedicalReportsTableTableManager get medicalReports =>
      $$MedicalReportsTableTableManager(_db, _db.medicalReports);
  $$TestResultsTableTableManager get testResults =>
      $$TestResultsTableTableManager(_db, _db.testResults);
}
