// RUN: %empty-directory(%t)
// RUN: %target-build-swift-dylib(%t/%target-library-name(resilient_struct)) -enable-library-evolution %S/../Inputs/resilient_struct.swift -emit-module -emit-module-path %t/resilient_struct.swiftmodule -module-name resilient_struct

// RUN: %target-swift-frontend -use-jit %s -emit-ir -lresilient_struct -L %t -I %t -enable-objc-interop -read-legacy-type-info-path=%S/Inputs/legacy_type_info/b.yaml | %FileCheck %s
// RUN: %target-swift-frontend -interpret %s -lresilient_struct -L %t -I %t -enable-objc-interop -read-legacy-type-info-path=%S/Inputs/legacy_type_info/b.yaml

// REQUIRES: objc_interop
// UNSUPPORTED: OS=ios || OS=watchos || OS=tvos

import resilient_struct

@_optimize(none) func blackHole<T>(_: T) {}

// ClassMetadataStrategy::Fixed
class FixedSizeClass {
    var v4: String?
    var v5: Int?
    var v6: String?
}

// ClassMetadataStrategy::Singleton
class GenericSuperclass<T> { }
class ClassWithGenericSuperclass: GenericSuperclass<Int> {
    var v1: ResilientDouble?
    var v2: ResilientDouble?
    var v3: ResilientDouble?
    var v4: String?
    var v5: Int?
    var v6: String?
}

// ClassMetadataStrategy::FixedOrUpdate when compiling
// ClassMetadataStrategy::Singleton when interpreting
class ClassNeedingUpdate {
    var v1: ResilientDouble?
    var v2: ResilientDouble?
    var v3: ResilientDouble?
    var v4: String?
    var v5: Int?
    var v6: String?
}

blackHole(FixedSizeClass())
blackHole(ClassWithGenericSuperclass())
blackHole(ClassNeedingUpdate())

// CHECK-LABEL: define{{( protected)?}} private void @runtime_registration
// CHECK:             call void @swift_instantiateObjCClass({{.*}} @"$s21jit_metadata_strategy14FixedSizeClassCN")
// CHECK-NOT:         call void @swift_instantiateObjCClass({{.*}} @"$s21jit_metadata_strategy18ClassNeedingUpdateCN")
