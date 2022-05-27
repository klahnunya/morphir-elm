module Morphir.JsonSchema.AST exposing (..)

{-
    {
      "$schema": "https://json-schema.org/draft/2020-12/schema",
      "$id" : "https://example.com/types.schema.json",
    }













    {
        "$id": "https://example.com/quantity.schema.json",
         "$schema": "https://json-schema.org/draft/2020-12/schema",
         "type": "integer",
         "$defs": {
            "Quantity": {
                "type": "integer"
            }
         }
    },
    {
        "$id": "https://example.com/cart.schema.json",
         "$schema": "https://json-schema.org/draft/2020-12/schema",
         "type": "array",
         "properties": {
            "Cart": {
                "type": "array",
                "items" : {
                    "type": "object"
                    "properties": {
                        "title":{
                            "type": "string"
                        },
                        "productQuantity": {
                            "$ref: "https://example.com/quantity.schema.json"
                        }
                    }
                }
            }
         }
    }
    {
        "$id": "https://example.com/custom.schema.json",
         "$schema": "https://json-schema.org/draft/2020-12/schema",
         "type": "object",
         "properties": {

         }
    },
    {
        $id": "https://example.com/int.schema.json",
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "integer",
    }
    {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "$id" : "https://example.com/types.schema.json",
        "title": "Types",
        "description": "Types ",
        "type": "object",
        "properties":{
            "Quantity" : {
                "type": "integer"
            },
            "Cart": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "title": "string",
                        "productQuantity": "Quantity"
                    }
                },
            },
            "Custom" :{
                "properties":{
                    "type": "array",
                    ""
                }
            }
            "FooBarBazRecord":{
                "properties":{
                    "foo": {
                        "description": "foo description",
                        "type": "string"
                    },
                    "bar": {
                        "description": "bar description",
                        "type": "bool"
                    },
                    "baz": {
                        "description": "baz description",
                        "type": "integer"
                    }
                }
            }
       }

    }
-}