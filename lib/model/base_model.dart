import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

/// Base class for all models that map to Supabase tables
abstract class BaseModel {
  /// The unique identifier of the model
  final String id;
  
  /// Constructor
  const BaseModel({required this.id});
  
  /// Creates a new instance with a generated UUID
  factory BaseModel.create() {
    return throw UnimplementedError('Subclasses must implement this');
  }
  
  /// Converts model to a map
  Map<String, dynamic> toJson();
  
  /// Creates a copy of this model with the given fields replaced
  BaseModel copyWith({String? id});
} 