package main

import (
	"C"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
	"unsafe"

	"github.com/fluent/fluent-bit-go/output"
	"github.com/google/uuid"
)
import (
	"bytes"
	"encoding/json"
)

var (
	gcsClient Client
	err       error
)

//export FLBPluginRegister
func FLBPluginRegister(def unsafe.Pointer) int {
	return output.FLBPluginRegister(def, "gcs", "GCS Output plugin written in GO!")
}

//export FLBPluginInit
func FLBPluginInit(plugin unsafe.Pointer) int {
	os.Setenv("GOOGLE_APPLICATION_CREDENTIALS", output.FLBPluginConfigKey(plugin, "Credentials"))
	gcsClient, err = NewClient()
	if err != nil {
		output.FLBPluginUnregister(plugin)
		fmt.Println(err)
		os.Exit(1)
		return output.FLB_ERROR
	}

	// Set the context
	output.FLBPluginSetContext(plugin, map[string]string{
		"region": output.FLBPluginConfigKey(plugin, "Region"),
		"bucket": output.FLBPluginConfigKey(plugin, "Bucket"),
		"prefix": output.FLBPluginConfigKey(plugin, "Prefix"),
	})

	return output.FLB_OK
}

//export FLBPluginFlushCtx
func FLBPluginFlushCtx(ctx, data unsafe.Pointer, length C.int, tag *C.char) int {
	// Type assert context back into the original type for the Go variable
	values := output.FLBPluginGetContext(ctx).(map[string]string)

	fmt.Printf("[gcs] Flush called, context %s, %s, %v\n", values["region"], values["bucket"], tag)

	dec := output.NewDecoder(data, int(length))

	for {
		ret, ts, record := output.GetRecord(dec)
		if ret != 0 {
			break
		}

		// Print record keys and values
		// timestamp := ts.(output.FLBTime)
		// fmt.Printf("%s: [%s, {", C.GoString(tag), timestamp.String())

		// for k, v := range record {
		// 	fmt.Printf("\"%s\": %v, ", k, v)
		// }
		// fmt.Printf("}\n")

		// Get timestamp
		var timestamp time.Time
		switch t := ts.(type) {
		case output.FLBTime:
			timestamp = ts.(output.FLBTime).Time
		case uint64:
			timestamp = time.Unix(int64(t), 0)
		default:
			fmt.Print("timestamp isn't known format. Use current time.\n")
			timestamp = time.Now()
		}

		line, err := createJSON(record)
		if err != nil {
			fmt.Printf("error creating message for S3: %v\n", err)
			continue
		}

		objectKey := GenerateObjectKey(values["bucket"], timestamp)
		if err = gcsClient.Write(values["bucket"], objectKey, bytes.NewReader(line)); err != nil {
			fmt.Printf("error sending message for S3: %v\n", err)
			return output.FLB_RETRY
		}
	}

	// Return options:
	//
	// output.FLB_OK    = data have been processed.
	// output.FLB_ERROR = unrecoverable error, do not try this again.
	// output.FLB_RETRY = retry to flush later
	return output.FLB_OK
}

// format is S3_PREFIX/S3_TRAILING_PREFIX/date/hour/timestamp_uuid.log
func GenerateObjectKey(S3Prefix string, t time.Time) string {
	timestamp := t.Format("20060102150405")
	date := t.Format("20060102")
	hour := strconv.Itoa(t.Hour())
	logUUID := uuid.Must(uuid.NewRandom()).String()
	fileName := strings.Join([]string{timestamp, "_", logUUID, ".log"}, "")

	objectKey := filepath.Join(S3Prefix, date, hour, fileName)
	return objectKey
}

func createJSON(record map[interface{}]interface{}) ([]byte, error) {
	m := make(map[string]interface{})

	for k, v := range record {
		switch t := v.(type) {
		case []byte:
			// prevent encoding to base64
			m[k.(string)] = string(t)
		default:
			m[k.(string)] = v
		}
	}

	js, err := json.Marshal(m)
	if err != nil {
		return []byte("{}"), err
	}

	return js, nil
}

//export FLBPluginExit
func FLBPluginExit() int {
	return output.FLB_OK
}

func main() {}
