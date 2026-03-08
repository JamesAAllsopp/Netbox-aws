# Netbox-aws
Terraform implementation of a Netbox installation on AWS

## psycopg2 in a lambda

This is tricky due to the necssity of getting this package into a lambda. Beware psycopg2-binary is not really the best way of doing this; perhaps your own compilation and there is a psycopg3 now. 

I resolved this by building a layer and uploading this, and then building the lambda off this.

Start with an empty directory. Then place your requirements.txt in it, which should just contain 
```
psycopg2-binary
```

Then run the following Docker container;
```
podman run --rm --entrypoint /bin/bash -v $(pwd):/var/task:Z public.ecr.aws/lambda/python:3.12 -c "pip install -r requirements.txt -t python/lib/python3.12/site-packages"
```

:Z is essential for SELinux labelling; not that you'll be warned.

then zip up the python directory with;
```
zip -r psycopg2-layer.zip python/
```

This is needed to handle the library situation within the lambda environment.

I then created this in the UI with

Name: psycopg-312
Version: 1
Description: psycopg2.12
Compatible runtimes: python3.12
Compatible architectures: x86_64
