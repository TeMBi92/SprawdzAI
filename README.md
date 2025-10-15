# T-Mobile PL Chat Assistant

Aplikacja webowa czatu dla pracowników T-Mobile Polska.

## Funkcjonalności

### ✅ Zaimplementowane wymagania:

1. **Dostęp** - Chat dostępny dla wszystkich pracowników T-Mobile PL
2. **Regulamin** - Przycisk regulaminu w nagłówku, dostępny w każdym momencie
3. **Nowa konwersacja** - Przycisk "Wyczyść" do rozpoczęcia nowej konwersacji
4. **Auto-focus** - Kursor automatycznie ustawiany w polu input przy otwarciu
5. **Limit znaków** - Maksymalnie 300 znaków z licznikiem
6. **Polskie znaki** - Pełne wsparcie dla polskich znaków diakrytycznych i znaków specjalnych
7. **Wysyłanie wiadomości** - Możliwość wysłania przez Enter lub przycisk "Wyślij"
8. **Prezentacja wiadomości** - Wiadomości wyświetlane w oknie czatu
9. **Kontynuacja konwersacji** - Możliwość wysyłania kolejnych wiadomości w tym samym wątku
10. **Loading indicator** - Animowana ikonka podczas oczekiwania na odpowiedź
11. **Różne kolory** - Wiadomości użytkownika (magenta) i bota (szare) w różnych kolorach
12. **Źródła** - Każda odpowiedź zawiera informację o źródle (jeśli dostępne)
13. **System feedbacku** - Kciuk w górę/dół pod każdą odpowiedzią z możliwością zmiany
14. **Logo T-Mobile** - Logo w nagłówku aplikacji

## Struktura plików

```
FE/
├── index.html          # Główna struktura HTML
├── styles.css          # Stylowanie w kolorach T-Mobile
├── script.js           # Logika aplikacji
├── assets/
│   └── tmobile-logo.svg # Logo T-Mobile
└── README.md           # Dokumentacja
```

## Uruchomienie

1. Otwórz plik `index.html` w przeglądarce internetowej
2. Lub uruchom lokalny serwer:
   ```bash
   # Python 3
   python -m http.server 8000
   
   # Następnie otwórz http://localhost:8000
   ```

## Kolory T-Mobile

- **Magenta**: #E20074 (główny kolor marki)
- **Ciemny Magenta**: #C10062 (hover states)
- **Szary**: #666666 (tekst)
- **Jasny Szary**: #F5F5F5 (tło)

## Funkcje JavaScript

### Główne funkcje:
- `sendMessage()` - Wysyłanie wiadomości do czatu
- `clearConversation()` - Czyszczenie historii konwersacji
- `displayUserMessage()` - Wyświetlanie wiadomości użytkownika
- `displayBotMessage()` - Wyświetlanie odpowiedzi bota
- `handleFeedback()` - Obsługa systemu ocen (kciuk w górę/dół)
- `getChatResponse()` - Pobieranie odpowiedzi (obecnie mock, do podłączenia API)

## Integracja z API

W pliku `script.js` znajduje się funkcja `getChatResponse()` która obecnie zwraca mock'owane odpowiedzi. 

Aby podłączyć prawdziwe API, zastąp tę funkcję wywołaniem do backend'u:

```javascript
async function getChatResponse(userMessage) {
    const response = await fetch('/api/chat', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            message: userMessage,
            conversationId: conversationId
        })
    });
    
    return await response.json();
}
```

## Obsługa Feedbacku

Feedback jest wysyłany przez funkcję `sendFeedbackToAPI()`. Format danych:

```javascript
{
    conversationId: string,  // ID konwersacji
    messageId: number,       // ID wiadomości
    feedback: 'positive' | 'negative' | null
}
```

## Responsywność

Aplikacja jest w pełni responsywna i dostosowuje się do różnych rozmiarów ekranów:
- Desktop: Pełny widok
- Tablet: Dostosowany layout
- Mobile: Pełny ekran z pionowym układem przycisków

## Licencja

© 2025 T-Mobile Polska
