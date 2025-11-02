source "null" "local" {
  communicator = "none"
}

build {
  name    = "local-test-image"
  sources = ["source.null.local"]

  provisioner "shell-local" {
    inline = [
      "echo 'Building local image...'",
      "mkdir -p output",
      "echo 'This is my local image build example' > output/image-info.txt",
      "echo 'Build completed successfully!'"
    ]
  }
}
