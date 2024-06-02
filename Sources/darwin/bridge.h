#ifndef bridge_h
#define bridge_h

#ifdef __cplusplus
extern "C" {
#endif

void startMouseMonitor(void (*callback)(const char*, int));

#ifdef __cplusplus
}
#endif

#endif /* bridge_h */
