
resource "aws_dynamodb_table" "counter_table" {
  name           = "resume-counter"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 4
  hash_key       = "count"

  attribute {
    name = "count"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "count_initialize" {
  table_name = aws_dynamodb_table.counter_table.name
  hash_key   = aws_dynamodb_table.counter_table.hash_key

  item = <<ITEM
{
  "count": {"S": "count"},
  "current_count": {"S": "0"}
}
ITEM

  depends_on = [aws_dynamodb_table.counter_table]
}
