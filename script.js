document.addEventListener('DOMContentLoaded', () => {
    const questions = [
        {
            q: "Which HTML5 tag is used to embed JavaScript code directly inside a web document?",
            options: ["<script>", "<js>", "<javascript>", "<code.js>"],
            answer: 0
        },
        {
            q: "What does CSS stand for in web engineering?",
            options: ["Creative Style System", "Cascading Style Sheets", "Computer Style Syntax", "Control Sheet System"],
            answer: 1
        },
        {
            q: "Which HTTP method is typically used to update or upload data payload to a server?",
            options: ["GET", "OPTIONS", "POST", "TRACE"],
            answer: 2
        },
        {
            q: "What is the primary scripting language used for Godot game engine development?",
            options: ["Python", "GDScript", "C#", "Lua"],
            answer: 1
        },
        {
            q: "Which JavaScript function schedules code execution at regular time intervals?",
            options: ["setTimeout()", "requestAnimationFrame()", "setInterval()", "delay()"],
            answer: 2
        }
    ];

    let currentIdx = 0;
    let score = 0;
    let timer = 15;
    let timerInterval;

    const startScreen = document.getElementById('startScreen');
    const quizScreen = document.getElementById('quizScreen');
    const resultScreen = document.getElementById('resultScreen');
    const startQuizBtn = document.getElementById('startQuizBtn');
    const restartQuizBtn = document.getElementById('restartQuizBtn');
    const questionText = document.getElementById('questionText');
    const optionsContainer = document.getElementById('optionsContainer');
    const questionNum = document.getElementById('questionNum');
    const timeLeft = document.getElementById('timeLeft');
    const scoreDisplay = document.getElementById('scoreDisplay');
    const finalScoreText = document.getElementById('finalScoreText');

    startQuizBtn.addEventListener('click', startQuiz);
    restartQuizBtn.addEventListener('click', startQuiz);

    function startQuiz() {
        currentIdx = 0;
        score = 0;
        scoreDisplay.textContent = score;
        startScreen.classList.add('hidden');
        resultScreen.classList.add('hidden');
        quizScreen.classList.remove('hidden');
        loadQuestion();
    }

    function loadQuestion() {
        clearInterval(timerInterval);
        timer = 15;
        timeLeft.textContent = timer;

        const currentQ = questions[currentIdx];
        questionNum.textContent = `Question ${currentIdx + 1} of ${questions.length}`;
        questionText.textContent = currentQ.q;
        optionsContainer.innerHTML = '';

        currentQ.options.forEach((opt, idx) => {
            const btn = document.createElement('button');
            btn.className = 'w-full text-left bg-slate-800/60 hover:bg-indigo-600/30 border border-slate-700 hover:border-indigo-500 p-4 rounded-xl font-medium text-slate-200 transition flex items-center gap-3 active:scale-98';
            btn.innerHTML = `<span class="w-8 h-8 bg-slate-700 rounded-lg flex items-center justify-center font-bold text-sm text-indigo-300">${String.fromCharCode(65 + idx)}</span> <span>${opt}</span>`;
            btn.addEventListener('click', () => selectAnswer(idx));
            optionsContainer.appendChild(btn);
        });

        timerInterval = setInterval(() => {
            timer--;
            timeLeft.textContent = timer;
            if (timer <= 0) {
                clearInterval(timerInterval);
                nextQuestion();
            }
        }, 1000);
    }

    function selectAnswer(selectedIdx) {
        clearInterval(timerInterval);
        const currentQ = questions[currentIdx];
        const buttons = optionsContainer.querySelectorAll('button');

        buttons.forEach((btn, idx) => {
            btn.disabled = true;
            if (idx === currentQ.answer) {
                btn.classList.remove('bg-slate-800/60', 'hover:bg-indigo-600/30', 'border-slate-700');
                btn.classList.add('bg-emerald-600/30', 'border-emerald-500', 'text-emerald-200');
            } else if (idx === selectedIdx) {
                btn.classList.remove('bg-slate-800/60', 'border-slate-700');
                btn.classList.add('bg-rose-600/30', 'border-rose-500', 'text-rose-200');
            }
        });

        if (selectedIdx === currentQ.answer) {
            score += 100 + timer * 10;
            scoreDisplay.textContent = score;
        }

        setTimeout(nextQuestion, 1200);
    }

    function nextQuestion() {
        currentIdx++;
        if (currentIdx < questions.length) {
            loadQuestion();
        } else {
            endQuiz();
        }
    }

    function endQuiz() {
        clearInterval(timerInterval);
        quizScreen.classList.add('hidden');
        resultScreen.classList.remove('hidden');
        finalScoreText.innerHTML = `You scored <span class="text-emerald-400 font-extrabold text-2xl">${score}</span> points!`;
    }
});
