# 1장. 객체, 설계

## 무엇이 문제인가

**소프트웨어 모듈의 3가지 목적:**

1. 실행중에 제대로 동작할 것
2. 변경을 위해 존재
3. 코드를 읽는 사람과 의사소통 할 것: 이해하기 쉬운 코드

### Theater 코드의 문제점 짚어보기

```swift
class Theater {
    private let ticketSeller: TicketSeller

    init(ticketSeller: TicketSeller) {
        self.ticketSeller = ticketSeller
    }

    /// 관람객을 맞이한다:
    func enter(audience: Audience) {
        // 관람객의 가방안에 초대장이 들어있는지 확인해 로직을 실행한다
        // 초청장을 가지고 있는 경우:
        // 초청장과 티켓을 교환한다
        if(audience.getBag().hasInvitation()) {
            let ticket = ticketSeller.getTicketOffice().getTicket()
            audience.getBag().setTicket(ticket)
            return
        }
        // 초청장이 없는 경우:
        // 1. 티켓판매처에서 티켓을 가져온다
        let ticket = ticketSeller.getTicketOffice().getTicket()
        // 2. 관람객의 가방에서 돈을 차감한다
        audience.getBag().minusAmount(ticket.getFee())
        // 3. 티켓값만큼 티켓판매처의 돈을 증가시킨다
        ticketSeller.getTicketOffice().plusAmount(ticket.getFee())
        // 4. 1에서 가져온 티켓을 관람객의 가방안에 넣어준다
        audience.getBag().setTicket(ticket)
    }
}
```

1. 소극장은 관람객의 가방을 열어 초대장이 있는지 확인
2. 초대장이 있다
   1. 매표소에 있는 티켓 하나를 관람객의 가방에 넣는다
3. 초대장이 없다
   1. 관람객의 가방에서 티켓가격 만큼의 amount(현금)을 꺼내 매표소에 넣는다.
   2. 매표소에서 티켓 하나를 꺼내 관람객의 가방에 넣는다.

⇒ 관람객과 판매원이 Theater 의 통제를 받는 수동적인 존재이다.

Theater 가 손님의 가방을 멋대로 헤집고 있는 상황이 발생하고 있다.

또한 매표소의 property(현금, 티켓들)에 멋대로 접근해 손대고 있다.

### 이해가능한 코드란:

예상에서 크게 벗어나지 않는 코드이다.

현실의 개념으로 보면,

- 관람객이 자신의 가방에서 초대장을 꺼내 판매원에게 건내는 것이 일반적이다.
- 티켓을 구매하는 관람객은 가방에서 돈을 직접 꺼내 판매원에게 지불한다.
- 판매원은 매표소에 있는 티켓을 직접 꺼내고 관람객에서 돈을 받아 매표소에 보관한다.

위의 코드는 이 상식과 동떨어져 있기 때문에 코드를 읽는 사람과 제대로 의사소통 할 수 없게 되었다.

```swift
let ticket = ticketSeller.getTicketOffice().getTicket()
audience.getBag().minusAmount(ticket.getFee())
ticketSeller.getTicketOffice().plusAmount(ticket.getFee())
audience.getBag().setTicket(ticket)
```

또한, 이 코드를 해석하기 위해서는 세부적인 내용들을 한꺼번에 기억하고 있어야 한다.

- `audience` 가 `Bag` 을 가지고 있어야 한다는 것을 알아야 한다.
- Bag 안에는 amount(현금), ticket 이 들어 있어야 한다는 것을 알아야 한다.
- `ticketSeller` 가 `TicketOffice` 를 알고 있어야 한다는 것을 알아야 한다.

위의 코드는 너무 많은 세부사항을 다루기때문에 코드를 작성하는 사람도, 읽는 사람도 모두에게 큰 부담을 준다.

`Audience` 와 `TicketSeller` 를 변경할 경우 `Theater` 도 함께 변경해야 하므로 이또한 심각한 문제점이 된다.

코드는 **다음과 같은 사항을 강제하고 있다:**

- 관람객이 현금과 초대장을 보관하기 위해서는 가방을 들고 다녀야 한다.
  - ⇒ 현금이 아닌, 신용카드로 티켓을 구매한다면?
- 판매원은 매표소에서만 티켓을 판매해야 한다.
  - ⇒ 매표소 밖에서 티켓을 판매해야 한다면?

지나치게 세부적인 사항에 의존하고 있다: 이를 **의존성(dependency)**이라고 한다.

이 세부사실중에 한가지라도 바뀌면 해당 클래스 뿐만 아니라, 이 클래스에 의존하는 클래스 또한 변경해야 한다.

`Audience` 의 내부에 대해 더 많이 알면 알수록 `Audience` 를 변경하기 어려워 진다 ⇒ **자유로운 객체로 만들자**

<br/>

### 자율성을 높여 문제 해결하기

`Theater` 가 관람객의 가방, 팬매원의 매표소에 접근

⇒ `Theater` 가 `Audience`, `TicketSeller`에 결합된다는 것.

해결방법: `Theater`가 `Audience`, `TiketSeller` 에 관해 세세한 부분까지 알지 못하도록 정보 차단.

예) 관람객이 가방(프로퍼티)을 가지고 있는 것은 `Theater`가 알 필요 없다.

`Theater`는 관람객이 소극장에 입장하는 것 뿐이다.

- 관람객: 가방안의 현금, 초대장 처리
  - Audience는 Bag 을 스스로 처리
- 판매원: 스스로 매표소의 티켓과 판매 요금을 다룸
  - `TikerSeller` 는 `TicketOffice`를 직접 처리

1. **Office에 접근하는 모든 코드를 TicketSeller 내부로 옮긴다**

`Theater` 는 `TicketSeller` 의 인터페이스(interface)에만 의존한다.

```swift
// Theater class
func enter(audience: Audience) {
    ticketSeller.sellTo(audience: audience)
}

// TicketSeller class
func sellTo(audience: Audience) {
    if(audience.getBag().hasInvitation()) {
        let ticket = ticketOffice.getTicket()
        audience.getBag().setTicket(ticket)
        return
    }
    let ticket = ticketOffice.getTicket()
    audience.getBag().minusAmount(ticket.getFee())
    ticketOffice.plusAmount(ticket.getFee())
    audience.getBag().setTicket(ticket)
}
```

`ticketOffice`에 대한 접근은 `TicketSeller` 안에서만 존재하게 된다.

이처럼 객체내부의 세부사항을 감추는 것을 캡슐화라고 부른다. 캡슐화의 목적은 변경하기 쉬운 객체를 만드는 것이다. 캡슐화를 통해 객체 내부로의 접근을 제한하면 객체와 객체사이의 **결합도**를 낮출수 있어 설계를 좀 더 쉽게 변경할 수 있다.

2. **판매원의 `sellTo` 메서드 리펙토링**

`Audience`가 자신의 자신의 가방을 탐색할 수 있게끔 `Bag` 존재를 캡슐화

```swift
// TicketSeller class
func sellTo(audience: Audience) {
    let ticketFee = audience.buy(ticket: ticketOffice.getTicket())
    ticketOffice.plusAmount(ticketFee)
}

// Audience class
func buy(ticket: Ticket) -> Int {
	  // 자신의 가방을 뒤져서 초대장이 있는지 확인
	if(bag.hasInvitation()) {
	    bag.setTicket(ticket)
	    return 0
	}
	bag.minusAmount(ticket.getFee())
	bag.setTicket(ticket)
	return ticket.getFee()
}
```

`Audience`와 `TicketSeller` 의 결합도가 낮아 졌다. (내부 구현이 캡슐화되어 Audience를 수정하더라도 TicketSeller 에는 영향을 미치지 않는다.

⇒ 내부 구현을 외부에 노출하지 않고 스스로 처리하는 자율적인 객체가 되었다.

(자신이 가지고 있는 소지품-프로퍼티를 스스로 관리한다)

데이터를 스스로 처리하는 객체를 만들면 결합도를 낮추고 응집도를 높일 수 있다.

**객체의 자율성을 높이는 설계가 이해하기 쉽고 유연한 설계를 만든다.**

외부의 간섭을 최대한 배제하고 메시지를 통해서만 협력을 하는 자율적인 객체들의 공동체를 만드는 것이 좋은 객체지향 설계를 만들 수 있는 길이다.

```
💡 응집도: 밀접하게 연관된 작업만을 수행하고 연관성 없는 작업은 다른 객체에게 위임
```

<br/>

## 책임의 이동(shift of responsibility)

작업의 흐름이 Theater 에 집중되어 있다면 곧 책임이 Theater 에 집중되어 있는 것과 같다.

```swift
// class Theater
func enter(audience: Audience) {
    if(audience.getBag().hasInvitation()) {
        let ticket = ticketSeller.getTicketOffice().getTicket()
        audience.getBag().setTicket(ticket)
        return
    }
    let ticket = ticketSeller.getTicketOffice().getTicket()
    audience.getBag().minusAmount(ticket.getFee())
    ticketSeller.getTicketOffice().plusAmount(ticket.getFee())
    audience.getBag().setTicket(ticket)
}
```

변경전인 위에 있는 코드는

- Theater 에 모든 책임이 몰려있다.
- 필요한 모든 객체에 의존적이다.
- 이는 변경에 취약하다.

이제 아래의 코드를 살펴보자:

```swift
// Theater class
func enter(audience: Audience) {
    ticketSeller.sellTo(audience: audience) //1
}

// TicketSeller class
func sellTo(audience: Audience) {} //2

// Audience class
func buy(ticket: Ticket) -> Int {} //3
```

하나의 기능을 제공하기 위해 필요한 책임이 여러 객체에 걸쳐 분산되어 있도록 수정했다.

- 각 객체에 적절한 책임이 분배되었다.
- 자기 자신의 문제를 스스로 해결한다

데이터를 스스로 처리하는 자율적인 객체를 만들면 결합도를 낮추고 응집도를 높일 수 있게 된다.

```
💡 코드에서 데이터와 그 데이터를 사용하는 프로세스가 별도의 객체에 위치하고 있다면,
절차적 프로그래밍 방식을 따르고 있을 확률이 높다.
데이터와 데이터를 사용하는 프로세스가 동일한 객체안에 위치한다면 객체지향 프로그래밍 방식에 따르고 있을 수 있다.
```

<br/>

### 객체지향 프로그래밍(Object-Oriented Programming)

데이터와 프로세스가 동일한 모듈 내부에 위치하도록 프로그래밍 하는 방식

- 하나의 변경이 있을때 그 여파가 여러 클래스로 전파되는 것을 억제
- 캡슐화를 통해 의존성을 관리 ⇒ 객체 사이의 결합도를 낮춘다

### 책임의 이동(shift of responsibility)

“작업의 흐름이 상위모듈 Theater에 의해 제어 된다” 는 것은 곧 “책임이 Theater 에 집중되어 있다.” 는 것.

객체지향 설계로 변경되고 난 후에는 제어 흐름이 각 객체에 적절하게 분산되어 있다는 것을 알 수 있다.

객체지향에서는 독재자가 존재하지 않는다. 각 객체는 자신을 스스로 책임진다.

<br/>

## 훌륭한 객체 지향 설계란

- 모든 객체들이 자율적으로 행동하는 설계.
  - 실세계에서는 생명이 없는 수동적인 존재라도(이상한 나라의 앨리스에서 카드군단) 객체지향의 세계로 넘어오는 순간 생명과 지능을 가진 존재로 다시 태어난다.
- 오늘 요구하는 기능을 온전히 수행하면서 내일 쉽게 변경할 수 있는 유연한 코드
  - 요구 사항은 항상 변경된다
  - 코드를 수정하면 버그가 생길 가능성이 높다. 그리고 버그는 코드를 수정하려는 의지를 꺾는다 ⇒ 요구사항 변경으로 인해 버그가 생길 수도 있다는 두려움을 얻는다
- 객체지향 패러다임은 사람이 세상을 바라보는 방식대로 코드를 작성할 수 있게 하는 것.

  - 객체의 행동을 예상할 수 있게 됨으로써 코드를 좀 더 쉽게 이해할 수 있게 된다.
  - 앱은 객체들의 상호작용을 통해 구현되며 상호작용은 메시지로 표현된다.

  ```swift
  TicketSeller ----(Message)buy----> Audience

  TicketSeller ----(Message)minusAmount----> Bag
  ```

  - 객체들이 협력하는 과정에서 객체들은 다른 객체에게 의존하게 된다.
  - TicketSeller 가 Audience 에게 메시지를 전달하기 위해서 Audience 를 알아야 한다. ⇒ 의존성이 생김 (완전히 자율적인 객체는 없다)
  - 객체가 주변 환경에 강하게 결합될수록 변경하기 어려워 짐 ⇒ 앱을 수정하기 어렵게 만든다
