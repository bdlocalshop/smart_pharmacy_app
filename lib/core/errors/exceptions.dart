/// Database and business domain exceptions.
class AppException implements Exception {
  final String message;
  final dynamic cause;

  AppException(this.message, [this.cause]);

  @override
  String toString() => 'AppException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

class InsufficientStockException extends AppException {
  final String productId;
  final int requestedQuantity;
  final int availableStock;

  InsufficientStockException({
    required this.productId,
    required this.requestedQuantity,
    required this.availableStock,
  }) : super(
          'Insufficient stock for product $productId: requested $requestedQuantity, available $availableStock',
        );
}

class ExpiredBatchSaleBlockedException extends AppException {
  final String batchNumber;
  final DateTime expiryDate;

  ExpiredBatchSaleBlockedException({
    required this.batchNumber,
    required this.expiryDate,
  }) : super(
          'Sale blocked: Batch $batchNumber expired on ${expiryDate.toIso8601String().split('T').first}. Expired stock cannot be sold.',
        );
}

class DatabaseBackupException extends AppException {
  DatabaseBackupException(super.message, [super.cause]);
}

class DatabaseRestoreException extends AppException {
  DatabaseRestoreException(super.message, [super.cause]);
}

class RecordNotFoundException extends AppException {
  RecordNotFoundException(String entity, String id)
      : super('Record of type $entity with ID $id was not found.');
}

