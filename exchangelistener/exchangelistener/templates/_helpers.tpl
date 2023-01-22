{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "exchangelistener.name" -}}
{{- printf "%s" (include "base-service.name" .) -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "exchangelistener.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "exchangelistener.chart" -}}
{{- printf "%s" (include "base-service.chart" .) -}}
{{- end -}}

{{/*
Get KubeVersion removing pre-release information.
TODO: .Capabilities.KubeVersion.GitVersion is deprecated in Helm 3, switch to .Capabilities.KubeVersion.Version after migration.
*/}}
{{- define "exchangelistener.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.GitVersion (regexFind "v[0-9]+\\.[0-9]+\\.[0-9]+" .Capabilities.KubeVersion.GitVersion ) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19.x" (include "exchangelistener.kubeVersion" .)) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "ingress.isStable" -}}
  {{- eq (include "ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "ingress.supportsIngressClassName" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "exchangelistener.kubeVersion" .))) -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "ingress.supportsPathType" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "exchangelistener.kubeVersion" .))) -}}
{{- end -}}

{{/*
Returns rabbitmq connection stirng.
*/}}
{{- define "rabbitmq.connectionString" -}}
  {{- if (not (empty .Values.RabbitMQ.RmqAmqpHost)) -}}
    {{ .Values.RabbitMQ.AmqpProtocol  | default "amqp" }}://{{ .Values.RabbitMQ.Login }}:{{ .Values.RabbitMQ.Password }}@{{ .Values.RabbitMQ.RmqAmqpHost }}:{{ .Values.RabbitMQ.AmqpPort }}/{{ .Values.RabbitMQ.VirtualHost }}
  {{- else -}}
    {{ .Values.RabbitMQ.AmqpProtocol  | default "amqp" }}://{{ .Values.RabbitMQ.Login }}:{{ .Values.RabbitMQ.Password }}@{{ .Values.RabbitMQ.HostApi }}:{{ .Values.RabbitMQ.AmqpPort }}/{{ .Values.RabbitMQ.VirtualHost }}
  {{- end -}}
{{- end -}}

{{/*
Returns rabbitmq API url.
*/}}
{{- define "rabbitmq.apiUrl" -}}
  {{- if (not (empty .Values.RabbitMQ.APIUrl)) -}}
    {{ .Values.RabbitMQ.APIUrl }}
  {{- else if (not (empty .Values.RabbitMQ.RmqApiHost)) -}}
    {{ .Values.RabbitMQ.HttpProtocol | default "http" }}://{{ .Values.RabbitMQ.RmqApiHost }}:{{ .Values.RabbitMQ.HttpPort }}
  {{- else -}}
    {{ .Values.RabbitMQ.HttpProtocol | default "http" }}://{{ .Values.RabbitMQ.Host }}:{{ .Values.RabbitMQ.HttpPort }}
  {{- end -}}
{{- end -}}

{{/*
Returns is rabbitmq support enabled.
*/}}
{{- define "rabbitmq.enabled" -}}
  {{- (and (not (empty .Values.RabbitMQ.QueueName)) (not (empty .Values.RabbitMQ.VirtualHost))) -}}
{{- end -}}

{{/*
Returns RabbitMQ credentials secret name.
*/}}
{{- define "rabbitmq.secretName" -}}
    {{- if .Values.RabbitMQ.ExistingSecret -}}
        {{- printf "%s" .Values.RabbitMQ.ExistingSecret -}}
    {{- else -}}
        {{- printf "%s-rabbitmq" (include "exchangelistener.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created for RabbitMQ.
*/}}
{{- define "rabbitmq.shouldCreateSecret" -}}
{{- if not .Values.RabbitMQ.ExistingSecret }}
    {{- true -}}
{{- else -}}
{{- end -}}
{{- end -}}

{{/*
Returns log4net config path.
*/}}
{{- define "log4net.mountPath" -}}
  {{ .Values.log4Net.mountPath | default "/app/config" }}/log4net.config
{{- end -}}

