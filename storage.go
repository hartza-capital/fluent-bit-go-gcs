package main

import (
	"context"
	"io"

	"cloud.google.com/go/storage"
)

// Client & Context Google Cloud
type Client struct {
	CTX context.Context
	GCS *storage.Client
}

// NewClient Google Cloud
func NewClient() (Client, error) {
	ctx := context.Background()
	client, err := storage.NewClient(ctx)
	if err != nil {
		return Client{}, err
	}

	return Client{
		CTX: ctx,
		GCS: client,
	}, nil
}

// Write content in object GCS
func (c Client) Write(bucket, object string, content io.Reader) error {
	wc := c.GCS.Bucket(bucket).Object(object).NewWriter(c.CTX)
	if _, err := io.Copy(wc, content); err != nil {
		return err
	}

	if err := wc.Close(); err != nil {
		return err
	}

	return nil
}
