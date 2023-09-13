## 목적

AWS Fargate Auto Scaling 시연을 [Terraform으로 구현](https://github.com/jeayoon/TechAssignment/blob/main/test/main.tf)

## Architecture

![Fargate](https://github.com/jeayoon/TechAssignment/assets/17561411/64d5f9e3-f6bb-4c76-9639-95d86fdfe5ba)


## AWS Fargate Auto Scaling 시연 결과

* Task 개수 : 최대 작업 수 4개, 최소 작업 수 1개
* Auto Scaling 조건 : Request(4000Req) 이상이면 Scale-Out
* 시연 방법 : `ab -n 10000 -c 100 -t 300s $ALB_DNS` 로 부하테스트 실행
* 결과 : 아래의 이미지 최소 작업 수(BlueBox), 부하테스트 실행 후 최대 작업 수(RedBox) 동작 확인

![ECSAutoScalingTestResult](https://user-images.githubusercontent.com/17561411/236883339-deb9e15c-2091-4c58-9811-60e7ecd7f58e.jpg)


## Terraform version

```
> terraform --version
Terraform v1.4.5
```
## Terraform apply progress

1. `~/.aws/credentials` 에 AWS access key & secret key 설정
2. `main.tf`에서 `backend "s3"`의 bucket 입력 후 `terraform init`
3. NW및 ECR Deploy(Task Deploy준비를 위한 사전 Apply)
   1. `main.tf`에서 182행에 있는`##---------Second Deploy---------`부터 맨 아랫 줄 까지 일시적으로 Command out함
   2. `terraform plan`
   3. `terraform apply`
4. Docker Image를 ECR에 Push
   1. ECR 작성 후 `푸시 명령 보기` 순서대로 실행 (Dockerfile파일有)
      1. Mac M1&M2일경우 `--platform linux/amd64` 옵션이 필요. (e.g. `docker build --platform linux/amd64 -t ecr-test .`)
5. `vars.tf`에서 `container_image`에 ECR image URL을 입력
6. ALB,ECS Deploy
   1. 3번에서 Command out부분을 삭제
   2. `terraform plan`
   3. `terraform apply`