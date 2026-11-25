# Distributed SVM (Dual) via Blended Dynamics

각 에이전트가 데이터 포인트를 하나씩 가지고 있는 상황에서, 이웃 에이전트와의 통신(커플링 이득 `k`)만으로 SVM 쌍대(dual) 문제를 분산적으로 푸는 blended dynamics 시뮬레이션입니다.
결과는 CVX로 직접 푼 중앙집중식 해(검은 점선: 결정 경계와 마진)와 비교해 그립니다.

## 파일 구성

| 파일 | 설명 |
| --- | --- |
| `SVM_Dual_Simulation.m` | 메인 스크립트. 데이터 생성 → 에이전트/인접 행렬 생성 → `w`, `b`, `z(alpha)` blended dynamics 적분 → 결과 플롯 |
| `Agent.m` | 에이전트 클래스. 각 에이전트의 상태(`w`, `b`, `z`, `alpha`)와 미분식 계산 |

## 요구 사항

- MATLAB R2017a 이상 (스크립트 내 로컬 함수, 문자열 `+` 연산 사용)
- Statistics and Machine Learning Toolbox (`random` 함수)
- [CVX](http://cvxr.com/cvx/) (기준 해 계산용 `dual_opt_val`)

## 실행 방법

MATLAB에서 이 폴더로 이동한 뒤 실행합니다.

```matlab
SVM_Dual_Simulation
```

- 20개의 2차원 데이터가 무작위로 생성되며, 각 에이전트는 무작위 그래프(노드당 2개 연결)로 이웃과 연결됩니다.
- `k = 1000`으로 시뮬레이션한 뒤, 이어서 `k = 300`으로 한 번 더 시뮬레이션하고 두 결과를 나란히 그립니다.
- `dt = 1e-4`, `time = 20` 설정에서 각 단계마다 200,000 스텝을 적분하므로 실행에 시간이 걸립니다. 진행 상황은 `verbose = 1`일 때 출력됩니다.
- `trajectory = 1`로 바꾸면 `z`, `alpha`의 시간 궤적도 그립니다.
- 결과를 재현하려면 스크립트 맨 앞에 `rng(1);` 처럼 시드를 지정하세요.
