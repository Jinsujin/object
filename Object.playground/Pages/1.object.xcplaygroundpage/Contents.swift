//: [Previous](@previous)

import Foundation

/**
 티켓 판매 애플리케이션

 이벤트 기획
 - 추첨을 통해 선정된 관람객에게 공연을 무료로 관람할 수 있는 초대장 발송
 
 조건
 - 이벤트에 당첨된 관람객과 그렇지 못한 관람객은 다른 방식으로 입장시킨다.
 - 이벤트에 당첨되지 않은 관람객은 티켓을 구매해야만 입장 가능
 
 관람객:
 관람객은 이벤트에 당첨된 사람과, 당첨되지 않은 사람으로 나뉠 수 있다.
 다음 3가지의 소지품을 가질 수 있다.
 - 초대장
 - 현금
 - 티켓
 관람객이 소극장에 입장하기 위한 2가지 방법
 - 매표소에서 초대장 -> 티켓교환
 - 현금으로 티켓구매
 
 이벤트 당첨자:
 가방에 현금과 초대장이 있다.
 - 티켓으로 교환할 초대장을 가짐
 
 이벤트에 당첨되지 않은 사람:
 초대장이 없다. => 돈주고 티켓을 사야 한다.
 
 매표소(TicketOffice)
 */


/// 초대장: 이벤트 당첨자에게 발송됨
class Invitation {
    /// 공연을 관람할 수 있는 초대 일자
    private var when: TimeInterval = .zero
}

/// 공연을 관람하기 위한 티켓
class Ticket {
    private var fee: Int = 0
    
    func getFee() -> Int {
        return fee
    }
}

/// 관람객이 가질 수 있는 소지품을 보관
class Bag {
    private var amount: Int // 현금
    private var invitation: Invitation? // 초대장
    private var ticket: Ticket?
    
    // 초대 안된사람: 현금
    init(amount: Int) {
        self.amount = amount
    }
    
    // 초대된 사람: 현금, 초대장
    init(amount: Int, invitation: Invitation) {
        self.amount = amount
        self.invitation = invitation
    }
    
    func hasInvitation() -> Bool {
        return invitation != nil
    }
    
    func hasTicket() -> Bool {
        return ticket != nil
    }
    
    func setTicket(_ ticket: Ticket) {
        self.ticket = ticket
    }
    
    func minusAmount(_ amount: Int) {
        self.amount -= amount
    }
    
    func plusAmount(_ amount: Int) {
        self.amount += amount
    }
}

/// 관람객
class Audience {
    private let bag: Bag
    
    init(bag: Bag) {
        self.bag = bag
    }
    
    func getBag() -> Bag {
        return self.bag
    }
}

/// 매표소
class TicketOffice {
    /// 판매 금액
    private var amount: Int
    
    /// 판매하거나 교환할 티켓 목록
    private var tickets: [Ticket] = []
    
    init(amount: Int, tickets: [Ticket]) {
        self.amount = amount
        self.tickets = tickets
    }
    
    func getTicket() -> Ticket {
        return self.tickets.removeFirst()
    }
    
    func minusAmount(_ amount: Int) {
        self.amount -= amount
    }
    
    func plusAmount(_ amount: Int) {
        self.amount += amount
    }
}

/// 판매원
class TicketSeller {
    /// 판매원은 자기가 일할 매표소를 알고있다.
    private let ticketOffice: TicketOffice
    
    init(ticketOffice: TicketOffice) {
        self.ticketOffice = ticketOffice
    }
    
    func getTicketOffice() -> TicketOffice {
        return self.ticketOffice
    }
}

/// 소극장
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

//: [Next](@next)
