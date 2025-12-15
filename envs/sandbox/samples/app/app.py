from flask import Flask, request, jsonify
import boto3, io
from PIL import Image
import os

app = Flask(__name__)
s3 = boto3.client('s3')
BUCKET = os.environ.get('BUCKET_NAME') or "image-resizer-ec2-sandbox-unique-12345"

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
