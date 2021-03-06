# 1주차. 1~4장 독후감

1. 협력하는 객체들의 공동체
2. 이상한 나라의 객체
3. 타입과 추상화
4. 역할, 책임, 협력

내가 얼마나 객체지향에 대해 얕게 알고 있었는지 돌아볼 수 있었다.

그동안 알고 있던 객체지향은 “멤버변수(값)와 메서드(동작)를 클래스 단위로 묶어 이들의 커뮤니케이션을 통해 프로그래밍하는 방법” 정도 였다. 실제로 이 개념을 이용해 설계할때 “커뮤니케이션을 어떻게 하는거지?” 라는 의문은 항상 방황하게 만들었다.

책 “객체지향의 사실과 오해” 는 제목 그대로 객체를 이용한 설계에 있어 좋은 지침서 라고 생각한다.

<br/>

## 이상한 나라의 객체

이 책에서는 계속해서 “이상한 나라의 앨리스”의 글귀를 가져온다. 처음에는 단순히 이해를 쉽게 하도록 하기 위해 쉬운 이야기를 가져왔구나 싶었지만 읽으면 읽을 수록 왜 이 동화를 택한 것인지 알 수 있었다.

객체를 이용한 설계는 곧 “이상한 나라의 앨리스” 세계를 창조해 내는 것이다.

실제 사물에서 본따와서 소프트웨어속의 객체를 만들지만 이 둘은 같다고 할 수 없다.

앨리스의 세계에서 토끼와 고양이, 하트 군단은 말을 한다. 하지만 실제 세계에서는 말을 할 수 없는 사실을 모두가 알고 있다.

소프트웨어 세계에서 예를 살펴보자. 여기 바리스타 객체와 커피 머신 객체가 있다:

```
(객체)바리스타 ---(message)커피콩 채워줘---> (객체)커피머신
```

바리스타가 커피머신에게 커피콩을 채워달라고 요청하면 커피머신 스스로 커피콩을 채운다. 마치 커피머신에게 자아가 있는 것처럼 말이다.

현실에서 일어날 수 없는 일이 소프트웨어에서는 일어난다. 개발자가 할 일은 이상한 객체를 만들고 책임을 분배해나가며 객체들이 자유롭게 소통할 수 있는 세계를 창조하는 일이다.

<br/>

## 완벽한 객체 보다 협력

이때까지 설계할때 클래스를 먼저 만들어 두고 나중에 연결을 어떻게 할 지 고민했었다. 이는 좋지 않은 설계 방식이라는 점을 알게 되었다.

```
[송신자]객체A(sender) --- 메시지(func) ---> [수신자]객체B(receiver)
```

객체 그 자체보다는 객체와 객체간의 협력에 초점을 맞춰야 한다.

소프트웨어는 결국 객체간의 상호작용(혹은 소통)으로 이루어지는 시스템이다. 각 객체는 그 객체만의 책임이 있으며 필요할때 다른 객체에게 협력을 요구할 수 있다.

<br/>

## 메시지

이 책에서 계속해서 강조하는 중요한 개념중 하나는 “메시지”이다.

멤버변수에 직접 접근해 값을 변경하는게 더 편하지 않을까 생각했고 이 방식으로 코드 구현을 많이 했었다. 왜 메시지가 중요 할까?

```
객체는 메시지를 통해 다른 객체에게 요청을 한다.
멤버변수의 변경이 필요할때도 메시지를 통해서 변경할 수 있다.
```

즉, 객체에서 다른 객체의 멤버변수에 접근해 값을 변경하는 것은 어떤 필요에 의해서 일어나는 일(요청)이다.

값을 변경하는데 분명 “의도”가 있을 것이며, “의도”는 책임과 연결된다고 할 수 있다.

매니저 객체가 바리스타(객체)에게 커피콩을 채우게 하려고 한다:

```swift
매니저 ---(message)커피콩 채워---> 바리스타
```

그러면 멤버변수에 직접 접근하는 방식과 메서드를 통한 방식의 차이를 살펴보자.

의사 코드로 구현하면 다음과 같다:

```swift
바리스타.커피콩 += 100 // 🚨 1.멤버변수에 직접 접근해 값 변경

바리스타.커피머신채우기() // ✨ 2.메시지를 통해 변경
```

1. 멤버변수 직접 접근:
   - 커피콩(멤버변수) 자체에 의존하게 된다.
   - 바리스타가 커피콩이 아닌 캡슐머신을 사용하게 되면 어떻게 될까, 클라리언트 코드를 모두 고쳐야 하는 불상사가 생길 것이다. `바리스타.캡슐 += 10`
2. 메시지를 통한 변경:

   - 커피머신을 채우는 책임(역할)은 온전히 바리스타에게만 주어진다. ⇒객체의 자율성
   - 클라이언트는 바리스타가 어떻게 커피머신을 채우게 되는지 신경쓰지 않을 수 있다. ⇒ 결합을 줄일 수 있다.
   - `커피머신채우기()` 라는 메시지를 전달만 할 수 있다면(역할), 바리스타가 누구든 상관없다. ⇒ 다형성

   ```swift
   protocol 바리스타 {
   	func 커피머신채우기()
   }

   class 공유: 바리스타 {
   	func 커피머신채우기()
   }

   class 강동원: 바리스타 {
   	func 커피머신채우기()
   }
   ```
