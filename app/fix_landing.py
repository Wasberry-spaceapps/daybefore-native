import re

with open("src/Landing.tsx", "r", encoding="utf-8") as f:
    content = f.read()

replacements = {
    "Write the day down. Work on what keeps repeating.": "Write the day down, then notice what keeps coming back.",
    "A private journal, and a place for the few things you keep getting wrong. Return to them, revise what you think, and read back, in your own words, whether you are changing.": "A private journal, with a quiet place for the few things you keep getting wrong, where you can return to them, reconsider what you believe about them, and read back, in your own words, whether you are changing.",
    "Free and local on your device. Encrypted. Sync only if you want it.": "It is free and stays on your device, encrypted, and sync is there only if you want it.",
    "Put the day down, and leave it there. A quiet page for what happened and what you made of it. Write for a minute or for an hour.": "Most days deserve a page, even a short one. Write down what happened and what you made of it, and then leave it alone until you want it again.",
    "Some things keep happening. Selfishness, jealousy, a short temper. Give each a name. Write what you think causes it and what you will try. When it comes back, return, add what happened, and revise the theory. Earlier versions stay, dated.": "Some things in us repeat: a short temper, a flash of envy, a small selfishness we only notice afterwards. Here you can give each one a name and write down what you think causes it and what you intend to try. When it returns, you come back, add what happened, and revise the theory if it no longer holds. The earlier versions stay where they were, dated, so you can watch your thinking change.",
    "One line is enough.": "A single line is enough to begin with.",
    "Why it happens, what you believe about it, what you will try next time.": "why you think it happens, what you believe about it, and what you will try next time.",
    "Each time it happens, add what happened. Change the theory when it stops being true.": "when it happens again, record what happened, and change the theory once it stops being true.",
    "Closing: After a few months, read it from the top. That is the evidence.": "After some months, read it through from the beginning. What you find there is better evidence than memory.",
    "Private by construction": "PRIVATE, AND YOURS TO KEEP",
    "Your entries are encrypted on your device before they are sent anywhere. We store text we cannot read. It also means we cannot recover it for you. At sign-up you receive a recovery key. Keep it somewhere safe.": "Everything you write is encrypted on your own device before it goes anywhere, so what we store is text we cannot read. The other side of that is that we cannot recover it for you either, which is why you receive a recovery key when you sign up. Please keep it somewhere safe.<br/><br/>Because a journal is often read over a shoulder, Day Before asks for your password again whenever you leave and come back, unless you tell it not to.<br/><br/>Your entries remain yours. You can export all of them at any time, as Markdown or as a PDF, and take them wherever you like.",
    "ON EVERY DEVICE YOU WRITE ON": "ON EVERY DEVICE YOU WRITE ON",
    "Web, Android, Windows and Mac, with iPhone to follow. Everything works offline. Turn on sync when you want your entries in more than one place.": "Day Before runs in the browser and as an app for Android, Windows and Mac, with iPhone to follow. It works offline, and you can turn on sync whenever you would like your entries in more than one place."
}

for old, new_text in replacements.items():
    content = content.replace(old, new_text)

with open("src/Landing.tsx", "w", encoding="utf-8") as f:
    f.write(content)
