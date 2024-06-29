## Set up

1. install gcloud and terraform
2. Connect to github repository via google cloud (example: https://github.com/MichaelKilgore/climb_service)
3. Enable Cloud Domains API
4. Enable Cloud DNS API
5. Create Cloud Domain in console
6. Create terraform.tfvars with following content:

```
project_id = "example-444401"
default_region = "us-central1"
default_zone = "us-central1-a"
service_account_number = "9248145814"
domain_name = "climb-service.dev"
dns_zone = "climb-service-dev"
```

2. terraform init
3. terraform plan
4. terraform apply


## Notes

1. Domain Mapping can take a while to actual finish. (It took me 13 mins)

## SQL Notes

gcloud components install cloud_sql_proxy

gcloud beta sql connect  postgres-instance

gcloud sql users set-password postgres \
--instance=postgres-instance \
--password=XXXXXX

SELECT * FROM climbing_location;
