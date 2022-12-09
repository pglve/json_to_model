import 'package:json_to_model/core/dart_declaration.dart';
import 'package:json_to_model/utils/extensions.dart';

class JsonModel {
  late String fileName;
  late String constructor;
  late String className;
  late String mixinClass;
  late String declaration;
  late String mockDeclaration;
  late String copyWith;
  late String cloneFunction;
  late String jsonFunctions;
  late String hashDeclarations;
  late String equalsDeclarations;
  late String imports;
  String? packageName;
  String? indexPath;
  String? enums;
  String? enumConverters;
  String? nestedClasses;
  String? nestedFactoryClasses;
  String? extendsClass;
  String? relativePath;
  String? classComment;

  JsonModel(
    this.fileName,
    List<DartDeclaration> dartDeclarations, {
    this.packageName,
    this.indexPath,
    this.relativePath,
    this.classComment,
  }) {
    final extendsClass = dartDeclarations.where((element) => element.extendsClass != null).toList();
    mixinClass = dartDeclarations
        .where(
          (element) => element.mixinClass != null,
        )
        .map((element) => element.mixinClass)
        .join(', ');

    className = fileName.toTitleCase();

    constructor = dartDeclarations.toConstructor(
      className,
      hasExtends: extendsClass.isNotEmpty,
      hasMixin: mixinClass.isNotEmpty,
    );

    declaration = dartDeclarations.toDeclarationStrings(className);
    mockDeclaration = dartDeclarations.toMockDeclarationStrings(className);
    copyWith = dartDeclarations.toCopyWith(className);
    cloneFunction = dartDeclarations.toCloneFunction(className);
    jsonFunctions = dartDeclarations.toJsonFunctions(className);
    equalsDeclarations = dartDeclarations.toEqualsDeclarationString();
    hashDeclarations = dartDeclarations.toHashDeclarationString();
    imports = dartDeclarations.toImportStrings(relativePath);
    enums = dartDeclarations.getEnums(className);
    nestedClasses = dartDeclarations.getNestedModelClasses();
    nestedFactoryClasses = dartDeclarations.getNestedFactoryClasses();

    if (extendsClass.isNotEmpty) {
      this.extendsClass = extendsClass[0].extendsClass;
    }
  }

  // model string from json map
  factory JsonModel.fromMap(
    String fileName,
    Map<String, dynamic> jsonMap, {
    String? packageName,
    String? indexPath,
    String? relativePath,
  }) {
    final dartDeclarations = <DartDeclaration>[];
    final dartDeclarations2 = <DartDeclaration>[];
    jsonMap.forEach((key, value) {
      return dartDeclarations.add(DartDeclaration.fromKeyValue(key, value));
    });
    dartDeclarations2.addAll(dartDeclarations.where((e) => e.comment == null));
    String? classComment;
    for (final declaration in dartDeclarations.where((e) => e.comment != null)) {
      if (declaration.name == 'class') {
        classComment = declaration.comment;
      } else {
        try {
          dartDeclarations2.where((e) => e.name == declaration.name).first.comment = declaration.comment;
        } catch (e) {
          print('\x1b[31merror: comment key ${declaration.name} cannot match\x1b[0m');
        }
      }
    }

    // add key to templatestring
    // add valuetype to templatestring
    return JsonModel(
      fileName,
      dartDeclarations2,
      relativePath: relativePath,
      packageName: packageName,
      indexPath: indexPath,
      classComment: classComment
    );
  }
}
