// Fetch the JSON file
fetch('games.json')
    .then(response => response.json())
    .then(data => {
        
        const pinnedSection = document.querySelector('.pinned-section');

        data.forEach(gameData => {

            if(gameData.name?.length < 1 || gameData.description?.length < 1) return;

            const gameElement = document.createElement('div');
            gameElement.classList.add('pinned-item');
            
            const title = document.createElement('a');
            title.className = "link";
            title.textContent = gameData.name;
            title.href = gameData.repo;
            title.target = "_blank";
            const description = document.createElement('p');
            description.textContent = gameData.description;

            gameElement.appendChild(title);
            gameElement.appendChild(description);

            pinnedSection.appendChild(gameElement);
        });
    })
    .catch(error => console.error('Error:', error));
