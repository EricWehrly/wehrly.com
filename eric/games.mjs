function makeLink(href, className) {
    const link = document.createElement('a');
    link.className = `icon ${className}`;
    link.href = href;
    link.target = "_blank";
    return link;
}

function playLink(gameData) {
    return makeLink(gameData.play, "play");
}

function githubLink(gameData) {
    return makeLink(gameData.repo, "github");
}

fetch('games.json')
    .then(response => response.json())
    .then(data => {
        
        const pinnedSection = document.querySelector('.pinned-section');

        data.forEach(gameData => {

            if(gameData.name?.length < 1 || gameData.description?.length < 1) return;

            const gameElement = document.createElement('div');
            gameElement.classList.add('pinned-item');
            
            const title = document.createElement('h3');
            const titleAnchor = document.createElement('a');
            titleAnchor.className = "link";
            titleAnchor.textContent = gameData.name;
            titleAnchor.href = gameData.repo;
            titleAnchor.target = "_blank";

            if(gameData.play) {
                const link = playLink(gameData);
                gameElement.appendChild(link);
            }

            if(gameData.repo) {
                const link = githubLink(gameData);                
                gameElement.appendChild(link);
            }

            const description = document.createElement('p');
            description.textContent = gameData.description;

            title.appendChild(titleAnchor);
            gameElement.appendChild(title);
            gameElement.appendChild(description);

            pinnedSection.appendChild(gameElement);
        });
    })
    .catch(error => console.error('Error:', error));
