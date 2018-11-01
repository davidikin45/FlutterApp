class ApiResponse<T> 
{
  final bool success;
  final T data;
  final String body;

  ApiResponse(this.success, this.body, this.data);
}