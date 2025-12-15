variable "ami" {}
variable "instance_type" { default = "t3.micro" }
variable "subnet_id" {}
variable "vpc_id" {}
variable "instance_profile" {}
variable "bucket_name" {}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.bucket_name}-ec2-sg"
  vpc_id      = var.vpc_id
  description = "Allow HTTP (5000) from API Gateway / internet for MVP"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.bucket_name}-ec2-sg" }
}

resource "aws_instance" "app" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = var.instance_profile
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e
    yum update -y || apt-get update -y
    if command -v yum >/dev/null 2>&1; then
      yum install -y python3 python3-pip
    else
      apt-get install -y python3 python3-pip
    fi
    pip3 install --upgrade pip
    pip3 install Pillow boto3 flask gunicorn

    cat > /home/ec2-user/app.py <<'PY'
    from flask import Flask, request, jsonify
    import boto3, io, os
    from PIL import Image

    app = Flask(__name__)
    s3 = boto3.client('s3')
    BUCKET = "${var.bucket_name}"

    @app.route('/resize', methods=['POST'])
    def resize():
        if 'file' not in request.files:
            return jsonify({"error":"file field required"}), 400
        f = request.files['file']
        try:
            img = Image.open(f.stream).convert("RGB")
            img.thumbnail((1024,1024))
            out = io.BytesIO()
            img.save(out, format='JPEG', quality=85)
            out.seek(0)
            key_resized = "resized/{}.jpg".format(f.filename or "upload")
            key_orig = "original/{}".format(f.filename or "upload.jpg")
            f.stream.seek(0)
            s3.put_object(Bucket=BUCKET, Key=key_orig, Body=f.stream.read())
            s3.put_object(Bucket=BUCKET, Key=key_resized, Body=out.read(), ContentType='image/jpeg')
            return jsonify({"resized_key": key_resized, "original_key": key_orig}), 200
        except Exception as e:
            return jsonify({"error": str(e)}), 500

    if __name__ == '__main__':
        app.run(host='0.0.0.0', port=5000)
    PY

    chown ec2-user:ec2-user /home/ec2-user/app.py
    su - ec2-user -c "nohup gunicorn --bind 0.0.0.0:5000 app:app > /home/ec2-user/gunicorn.log 2>&1 &"
  EOF

  tags = { Name = "image-resizer-ec2" }
}

output "public_ip"  { value = aws_instance.app.public_ip }
output "public_dns" { value = aws_instance.app.public_dns }
