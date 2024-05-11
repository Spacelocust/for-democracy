// Atlas configuration file (e.g https://atlasgo.io/guides/orms/gorm)

data "external_schema" "gorm" {
  program = [
    "go",
    "run",
    "-mod=mod",
    "./database/loader/loader.go",
  ]
}

variable "url" {
  type = string
  default = getenv("DB_URL_DEV")
}

env "gorm" {
  src = data.external_schema.gorm.url
  dev = var.url
  migration {
    dir = "file://database/migration"
  }
  format {
    migrate {
      diff = "{{ sql . \"  \" }}"
    }
  }
}
