/// Screen fetches stay failed until the retry button. Riverpod's default
/// backoff would also retry contract errors (closed, not found, validation),
/// which will not succeed on their own.
Duration? noAutomaticRetry(int retryCount, Object error) => null;
