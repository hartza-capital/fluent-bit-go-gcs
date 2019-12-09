# fluent-bit gcs output plugin

This plugin works with fluent-bit's go plugin interface. You can use fluent-bit-go-gcs to ship logs into GCP Storage.

The configuration typically looks like:

```
Fluent-Bit --> Google Cloud Storage <-- Google Cloud BigQuery
```

# Usage

```bash
$ fluent-bit -e /path/to/built/out_gcs.so -c fluent-bit.conf
```

# Prerequisites

* Go 1.13+
* gcc (for cgo)

## Building

Library:
```bash
$ make
```

Container Image:
```bash
$ make build
```

### Configuration Options

| Key             | Description               | Default value | Note                    |
|-----------------|---------------------------|---------------|-------------------------|
| Credential      | Path of GCP credential    | `-`           | Mandatory parameter     |
| Bucket          | Bucket name of GCS        | `-`           | Mandatory parameter     |
| Prefix          | Prefix of GCS key         | `-`           | Mandatory parameter     |
| Region          | Region of GCS             | `-`           | Mandatory parameter     |

Example:

add this section to fluent-bit.conf

```properties
[Output]
    Name 		gcs
    Match 		*
    Credential  /path/to/sharedcredentialfile
    Bucket      yourbucketname
    Prefix 		yourgcsprefixname
    Region 		europe-west1
```