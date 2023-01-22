{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "base-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "base-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* labels */}}
{{- define "labels" -}}
{{ printf "app.kubernetes.io/name: %s-%s" (include "base-service.name" .root) (.prefix)  }}
{{ printf "app.kubernetes.io/instance: %s" .root.Release.Name }}
{{ printf "app.kubernetes.io/managed-by: %s" .root.Release.Service }}
{{ printf "helm.sh/chart: %s" (include "base-service.chart" .root) }}
{{ printf "app: %s-%s" (include "base-service.name" .root) (.prefix) }}
{{ printf "version: %s" .root.Chart.Version }}
{{- end -}}
