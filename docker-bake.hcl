target "local-db-copy" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}

target "16" {
  inherits = ["local-db-copy"]
  tags = ["ghcr.io/frederikhs/local-db-copy:16", "ghcr.io/frederikhs/local-db-copy:latest"]
  args = {
    PG_VERSION: "16"
  }
}

target "15" {
  inherits = ["local-db-copy"]
  tags = ["ghcr.io/frederikhs/local-db-copy:15"]
  args = {
    PG_VERSION: "15"
  }
}

target "14" {
  inherits = ["local-db-copy"]
  tags = ["ghcr.io/frederikhs/local-db-copy:14"]
  args = {
    PG_VERSION: "14"
  }
}

group "default" {
  targets = ["16", "15", "14"]
}

# docker buildx bake --set '*.platform=linux/amd64'
