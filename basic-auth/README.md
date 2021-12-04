# 注意

SecretやConfigMapからBasic認証のcredentialを設定する方法がないため現時点ではmanifestに直書きになってしまうことに注意する。

そのため、`Productionで広く利用されるようなものには絶対適用しない。`

[vm_configがEnvironmentVariable](https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/wasm/v3/wasm.proto#extensions-wasm-v3-vmconfig) が利用できるため、
[Customizing injection](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#customizing-injection)を使ってsidecar proxyに環境変数入れてインジェクションすることは可能かも？(要調査)

# これは？

istio, envoyを用いてBasic認証をかけるためのsample manifest

基本的に、[オフィシャルのサンプル](https://istio.io/latest/docs/ops/configuration/extensibility/wasm-module-distribution/)があるのでそれに従った。
`basic-auth` という名前のdeploymentを作成し、URL `https://$HOST/ip` 以下にアクセスしたときにBasic認証が行われるようになる。

### tips

オフィシャルのサンプルと違う部分はサンプルのままだとIngress Gatewayに適用され、Cluster全体にWASMが適用されてしまうため、
`spec.configPatches[].match.context=SIDECAR_INBOUND` に変更を行い適用する範囲をSidecar proxyのINBOUNDに絞った。

```diff
diff --git a/example/basic-auth/basic-auth-filter.yaml b/example/basic-auth/basic-auth-filter.yaml
index 0116d1a0..7073e4cd 100644
--- a/example/basic-auth/basic-auth-filter.yaml
+++ b/example/basic-auth/basic-auth-filter.yaml
@@ -7,7 +7,7 @@ spec:
  configPatches:
  - applyTo: HTTP_FILTER
    match:
-     context: GATEWAY
+     context: SIDECAR_INBOUND
      listener:
        filterChain:
          filter:
```

### 参考

- https://istio.io/latest/docs/ops/configuration/extensibility/wasm-module-distribution/
- https://github.com/istio-ecosystem/wasm-extensions/tree/master/extensions/basic_auth

