{{/*
Expand the name of the chart.
*/}}
{{- define "redis-tls-example.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "redis-tls-example.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "redis-tls-example.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "redis-tls-example.labels" -}}
helm.sh/chart: {{ include "redis-tls-example.chart" . }}
{{ include "redis-tls-example.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Redis Master labels
*/}}
{{- define "redis-tls-example.redis-master-labels" -}}
{{ .Values.roleText.tag }}: {{ .Values.roleText.master }}
{{- end }}

{{/*
Redis Client labels
*/}}
{{- define "redis-tls-example.redis-client-labels" -}}
{{ .Values.roleText.tag }}: {{ .Values.roleText.client }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "redis-tls-example.selectorLabels" -}}
app.kubernetes.io/name: {{ include "redis-tls-example.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "redis-tls-example.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "redis-tls-example.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "redis-tls-example.generate-certificates" -}}
{{- $altNames := list ( printf "%s.%s" (include "redis-tls-example.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "redis-tls-example.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "redis-tls-example-ca" 365 -}}
{{- $clientCert := genSignedCert ( include "redis-tls-example.name" . ) nil $altNames 365 $ca -}}
{{- $serverCert := genSignedCert ( include "redis-tls-example.name" . ) nil $altNames 365 $ca -}}
ca.crt: {{ $ca.Cert | b64enc }}
ca.key: {{ $ca.Key | b64enc }}
server.crt: {{ $serverCert.Cert | b64enc }}
server.key: {{ $serverCert.Key | b64enc }}
client.crt: {{ $clientCert.Cert | b64enc }}
client.key: {{ $clientCert.Key | b64enc }}
{{- end -}}
