resource "aws_dynamodb_table" "table" {
  name           = var.resource_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "stat"

  attribute {
    name = "stat"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "viewcount" {
  table_name = aws_dynamodb_table.table.name
  hash_key   = aws_dynamodb_table.table.hash_key

  item = <<ITEM
{
  "stat": {"S": "view-count"},
  "quantity": {"N": "0"}
}
ITEM

  lifecycle {
    ignore_changes = [
      # Ignore changes to item
      item
    ]
  }
}
