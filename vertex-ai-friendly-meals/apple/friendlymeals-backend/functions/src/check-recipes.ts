import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

// Initialize Firebase Admin
const app = initializeApp();
const db = getFirestore(app);

// Set emulator settings
db.settings({
	host: 'localhost:8080',
	ssl: false
});

async function checkRecipes() {
	try {
		const recipesCollection = db.collection('recipes');
		const snapshot = await recipesCollection.get();

		if (snapshot.empty) {
			console.log('No recipes found in the database');
			return;
		}

		console.log(`Found ${snapshot.size} recipes:`);
		snapshot.forEach(doc => {
			console.log(`- ${doc.id}: ${doc.data().title}`);
		});
	} catch (error) {
		console.error('Error checking recipes:', error);
	}
}

// Run the check
checkRecipes()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error('Failed to check recipes:', error);
		process.exit(1);
	}); 