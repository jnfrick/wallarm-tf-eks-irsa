# wallarm-tf-eks-irsa

This is a Terraform config example of how to deploy Wallarm via Helm Charts to an existing AWS EKS cluster using an existing AWS IAM IRSA role.  While there is a Wallarm Terraform module, it doesn't support EKS as of yet so this uses basic Helm, EKS, K8s, and AWS IAM modules.  The config will create a serviceAccount object in the cluster and associate the IRSA ARN to the serviceAccount object.  It will then install Wallarm Ingress Controller to the EKS cluster with a Helm value chart and have Wallarm use that IRSA. 

Pre-requisites:
* Existing EKS cluster in AWS
* Existing AWS IAM IRSA role
* Terraform, AWS CLI, and Helm installed locally

Once deployed, you can annotate your ingresses as follows to enable Wallarm in a specific mode and set an application ID:
```
kubectl annotate ingress <YOUR_INGRESS_NAME> -n <YOUR_INGRESS_NAMESPACE> nginx.ingress.kubernetes.io/wallarm-mode=monitoring
kubectl annotate ingress <YOUR_INGRESS_NAME> -n <YOUR_INGRESS_NAMESPACE> nginx.ingress.kubernetes.io/wallarm-application="<APPLICATION_ID>"
```

Now check funcionality of Wallarm pods:
```
kubectl get pods -n <WALLARM_NAMESPACE> -l app.kubernetes.io/name=wallarm-ingress
```

Ensure `STATUS: Running` and `READY: N/N`:
```
NAME                                                              READY     STATUS    RESTARTS   AGE
ingress-controller-nginx-ingress-controller-xxxxxxxxxx-xxxxx      3/3       Running   0          5m
ingress-controller-nginx-ingress-controller-wallarm-tarantxxxxx   4/4       Running   0          5m
```

Check to ensure Wallarm node registered to your tenant:
Wallarm Console > Nodes

Find Load Balancer assigned to Wallarm in K8s:
```
kubectl get svc -n <WALLARM_NAMESPACE>
```

```
NAMESPACE     NAME                                TYPE           CLUSTER-IP       EXTERNAL-IP                          PORT(S)                      AGE
wallarm       wallarm-wallarm-ingress-controller  LoadBalancer   10.100.130.148   a2134-etc.region.elb.amazonaws.com   80:32196/TCP,443:32028/TCP   5m26s
```

Update your site's DNS to point to the Load Balancer associated with the Wallarm Ingress Controller K8s service under `EXTERNAL-IP`

Check detection:
```
curl https://<YOUR_SITE>/etc/passwd
```

Review Wallarm console in Attacks section to ensure attack was detected and the source IP is correctly reported.
