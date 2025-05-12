import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

// Check if we're running in the emulator environment
const isEmulator = process.env.FIRESTORE_EMULATOR_HOST !== undefined;

// Initialize Firebase Admin
console.log('Environment details:');
console.log('- NODE_ENV:', process.env.NODE_ENV);
console.log('- FUNCTIONS_EMULATOR:', process.env.FUNCTIONS_EMULATOR);
console.log('- FIREBASE_CONFIG:', process.env.FIREBASE_CONFIG);
console.log('- GCLOUD_PROJECT:', process.env.GCLOUD_PROJECT);

// Check if we're running locally by looking for the service account file
const serviceAccountPath = '/Users/peterfriese/Workspace/products/VertexAI-Firebase/code/FriendlyMeals/service-accounts/service-account.json';
const isLocal = process.env.NODE_ENV === 'development' ||
	process.env.FUNCTIONS_EMULATOR === 'true' ||
	require('fs').existsSync(serviceAccountPath);

let app;
if (isLocal) {
	console.log('Initializing Firebase Admin with service account for local development');
	console.log('Service account path:', serviceAccountPath);
	try {
		app = initializeApp({
			credential: cert(serviceAccountPath),
			projectId: 'peterfriese-friendly-meals-04'
		});
	} catch (error) {
		console.error('Error initializing Firebase Admin with service account:', error);
		throw error;
	}
} else {
	console.log('Initializing Firebase Admin with default credentials for cloud environment');
	app = initializeApp();
}
console.log('Firebase Admin initialized successfully');

const db = getFirestore(app);

// If running in emulator, set the emulator host
if (isEmulator) {
	console.log('Running in emulator mode');
	db.settings({
		host: 'localhost:8080',
		ssl: false
	});
} else {
	console.log('Running in production mode');
}

// Define the Cuisine enum
enum Cuisine {
	italian = 'italian',
	mexican = 'mexican',
	indian = 'indian',
	chinese = 'chinese',
	japanese = 'japanese',
	thai = 'thai',
	mediterranean = 'mediterranean',
	american = 'american',
	french = 'french'
}

// Define the Recipe interface
interface Recipe {
	id: string;
	title: string;
	description: string;
	cuisine: Cuisine;
	cookingTimeInMinutes: number;
	imageURL: string;
	ingredientsList: string[];
	instructions: string[];
}

// Mock recipes data
const mockRecipes: Recipe[] = [
	{
		id: '1',
		title: 'Spaghetti Carbonara',
		description: 'Classic Italian pasta dish made with eggs, cheese, pancetta, and black pepper. A creamy and delicious comfort food that\'s ready in minutes.',
		cuisine: Cuisine.italian,
		cookingTimeInMinutes: 25,
		imageURL: 'https://images.pexels.com/photos/6287527/pexels-photo-6287527.jpeg',
		ingredientsList: [
			'1 pound spaghetti',
			'4 ounces pancetta, diced',
			'4 large eggs',
			'1 cup freshly grated Pecorino Romano',
			'1 cup freshly grated Parmigiano-Reggiano',
			'2 cloves garlic, minced',
			'2 tablespoons olive oil',
			'Freshly ground black pepper',
			'Salt'
		],
		instructions: [
			'Bring a large pot of salted water to boil. Add spaghetti and cook until al dente.',
			'While pasta cooks, heat olive oil in a large skillet over medium heat. Add pancetta and cook until crispy. Add garlic and cook for 1 minute.',
			'In a bowl, whisk together eggs, both cheeses, and plenty of black pepper.',
			'Reserve 1 cup of pasta water, then drain pasta.',
			'Working quickly, add hot pasta to skillet with pancetta. Toss to combine.',
			'Remove from heat and add egg mixture, tossing quickly to create a creamy sauce.',
			'Add pasta water as needed to achieve desired consistency.',
			'Season with salt and more pepper to taste. Serve immediately with extra cheese.'
		]
	},
	{
		id: '2',
		title: 'Pad Thai',
		description: 'Authentic Thai stir-fried rice noodles with tofu, shrimp, peanuts, and bean sprouts. Sweet, sour, and slightly spicy flavors combine in this popular dish.',
		cuisine: Cuisine.thai,
		cookingTimeInMinutes: 35,
		imageURL: 'https://images.pexels.com/photos/12365244/pexels-photo-12365244.jpeg',
		ingredientsList: [
			'1 cup rice noodles',
			'2 tablespoons vegetable oil',
			'1 onion, thinly sliced',
			'2 cloves garlic, minced',
			'1 cup mixed vegetables (bean sprouts, carrots, green onions)',
			'1 cup cooked shrimp',
			'1/2 cup tofu, cut into small pieces',
			'2 tablespoons tamarind paste',
			'2 tablespoons fish sauce',
			'1 tablespoon palm sugar',
			'1/4 teaspoon ground white pepper',
			'Salt',
			'2 tablespoons chopped peanuts',
			'2 tablespoons chopped fresh cilantro',
			'2 lime wedges'
		],
		instructions: [
			'Cook rice noodles according to package instructions. Drain and set aside.',
			'Heat oil in a large skillet or wok over medium-high heat. Add onion and garlic and cook until onion is translucent.',
			'Add mixed vegetables, cooked shrimp, and tofu. Cook for 2-3 minutes.',
			'Add tamarind paste, fish sauce, palm sugar, and white pepper. Stir to combine.',
			'Add cooked noodles to the skillet or wok. Stir to combine with the sauce and vegetables.',
			'Season with salt to taste. Transfer to a serving platter.',
			'Garnish with chopped peanuts, cilantro, and lime wedges. Serve immediately.'
		]
	},
	{
		id: '3',
		title: 'Mediterranean Bowl',
		description: 'Fresh and healthy bowl with quinoa, hummus, falafel, and mixed vegetables. Topped with tahini dressing and fresh herbs.',
		cuisine: Cuisine.mediterranean,
		cookingTimeInMinutes: 40,
		imageURL: 'https://images.pexels.com/photos/5741874/pexels-photo-5741874.jpeg',
		ingredientsList: [
			'1 cup quinoa',
			'2 cups water',
			'1/4 cup hummus',
			'4 falafel',
			'1 cup mixed vegetables (cucumber, tomatoes, bell peppers)',
			'1/4 cup tahini',
			'2 tablespoons lemon juice',
			'1 garlic clove, minced',
			'Salt and pepper',
			'Fresh parsley, chopped'
		],
		instructions: [
			'Cook quinoa according to package instructions. Set aside.',
			'Prepare hummus according to package instructions. Set aside.',
			'Cook falafel according to package instructions. Set aside.',
			'Prepare mixed vegetables by slicing and chopping.',
			'In a bowl, whisk together tahini, lemon juice, garlic, salt, and pepper.',
			'To assemble the bowl, place a scoop of quinoa on the bottom. Top with hummus, falafel, and mixed vegetables.',
			'Drizzle with tahini dressing and garnish with chopped parsley. Serve immediately.'
		]
	},
	{
		id: '4',
		title: 'California Sushi Roll',
		description: 'Inside-out sushi roll with crab meat, avocado, cucumber, and tobiko. Served with pickled ginger, wasabi, and soy sauce.',
		cuisine: Cuisine.american,
		cookingTimeInMinutes: 45,
		imageURL: 'https://images.pexels.com/photos/2098085/pexels-photo-2098085.jpeg',
		ingredientsList: [
			'1 cup cooked sushi rice',
			'1/2 cup crab meat',
			'1/2 avocado, sliced',
			'1/2 cucumber, sliced',
			'1/4 cup tobiko',
			'1 sheet nori seaweed',
			'Pickled ginger, wasabi, and soy sauce for serving'
		],
		instructions: [
			'Prepare sushi rice according to package instructions. Set aside.',
			'Prepare crab meat by flaking and mixing with mayonnaise.',
			'Prepare avocado and cucumber by slicing.',
			'Assemble the sushi roll by spreading a thin layer of sushi rice onto the nori seaweed.',
			'Add crab meat, avocado, and cucumber in the middle of the rice.',
			'Roll the sushi using a bamboo sushi mat.',
			'Slice into individual pieces and serve with pickled ginger, wasabi, and soy sauce.'
		]
	},
	{
		id: '5',
		title: 'Classic Cheeseburger',
		description: 'Juicy beef patty with melted cheddar, fresh lettuce, tomato, and special sauce on a toasted brioche bun. Served with crispy fries.',
		cuisine: Cuisine.american,
		cookingTimeInMinutes: 20,
		imageURL: 'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg',
		ingredientsList: [
			'1 pound ground beef',
			'1/4 cup grated cheddar cheese',
			'1/4 cup sliced lettuce',
			'1/4 cup sliced tomato',
			'2 tablespoons special sauce',
			'1 brioche bun',
			'Crispy fries for serving'
		],
		instructions: [
			'Prepare ground beef by forming into patties.',
			'Grill or cook beef patties until cooked to desired doneness.',
			'Assemble the burger by spreading special sauce on the bottom bun.',
			'Add a cooked beef patty, melted cheddar cheese, lettuce, and tomato.',
			'Top with the top bun.',
			'Serve with crispy fries.'
		]
	},
	{
		id: '6',
		title: 'Chicken Tikka Masala',
		description: 'Tender chicken pieces in a rich, creamy tomato-based curry sauce. Aromatic Indian spices create a flavorful dish perfect with naan bread.',
		cuisine: Cuisine.indian,
		cookingTimeInMinutes: 50,
		imageURL: 'https://images.pexels.com/photos/2474661/pexels-photo-2474661.jpeg',
		ingredientsList: [
			'1 pound boneless, skinless chicken breast',
			'1/2 cup plain yogurt',
			'2 tablespoons lemon juice',
			'2 tablespoons ghee or vegetable oil',
			'2 teaspoons garam masala',
			'1 teaspoon ground cumin',
			'1/2 teaspoon ground coriander',
			'1/2 teaspoon cayenne pepper',
			'1 can diced tomatoes',
			'1 cup chicken broth',
			'1 tablespoon tomato paste',
			'2 carrots, peeled and chopped',
			'2 celery stalks, chopped',
			'1 teaspoon dried thyme',
			'Salt and pepper',
			'Fresh cilantro, chopped'
		],
		instructions: [
			'Prepare chicken by marinating in yogurt, lemon juice, and spices.',
			'Grill or cook chicken until cooked through.',
			'Prepare curry sauce by heating oil in a large skillet over medium heat.',
			'Add onions, ginger, and garlic and cook until onions are translucent.',
			'Add spices and cook for 1 minute.',
			'Add diced tomatoes and chicken broth. Bring to a simmer.',
			'Add cooked chicken to the curry sauce and stir to combine.',
			'Season with salt and pepper to taste. Garnish with chopped cilantro. Serve with naan bread.'
		]
	},
	{
		id: '7',
		title: 'Beef Enchiladas',
		description: 'Corn tortillas filled with seasoned ground beef, topped with enchilada sauce and melted cheese. Garnished with sour cream and cilantro.',
		cuisine: Cuisine.mexican,
		cookingTimeInMinutes: 55,
		imageURL: 'https://images.pexels.com/photos/2673353/pexels-photo-2673353.jpeg',
		ingredientsList: [
			'1 pound ground beef',
			'1/2 cup chopped onion',
			'1/2 cup chopped bell pepper',
			'1 jalapeno pepper, chopped',
			'2 cloves garlic, minced',
			'1 packet taco seasoning',
			'8 corn tortillas',
			'1 can enchilada sauce',
			'1 cup shredded cheese',
			'Sour cream and cilantro for garnish'
		],
		instructions: [
			'Prepare ground beef by cooking in a large skillet over medium-high heat.',
			'Add onion, bell pepper, and jalapeno. Cook until vegetables are tender.',
			'Add garlic and taco seasoning. Cook for 1 minute.',
			'Prepare enchilada sauce according to package instructions.',
			'Assemble the enchiladas by filling tortillas with beef mixture and rolling up.',
			'Place rolled tortillas in a baking dish and cover with enchilada sauce and cheese.',
			'Bake until cheese is melted and bubbly.',
			'Garnish with sour cream and cilantro. Serve hot.'
		]
	},
	{
		id: '8',
		title: 'Coq au Vin',
		description: 'Classic French braised chicken with red wine, mushrooms, pearl onions, and bacon. Rich and hearty countryside cuisine.',
		cuisine: Cuisine.french,
		cookingTimeInMinutes: 90,
		imageURL: 'https://images.pexels.com/photos/2673353/pexels-photo-2673353.jpeg',
		ingredientsList: [
			'1 whole chicken, cut into 8 pieces',
			'6 slices bacon, diced',
			'1 onion, chopped',
			'2 cloves garlic, minced',
			'2 cups mixed mushrooms',
			'1 cup pearl onions',
			'1 cup red wine',
			'1 cup chicken broth',
			'1 tablespoon tomato paste',
			'2 carrots, peeled and chopped',
			'2 celery stalks, chopped',
			'1 teaspoon dried thyme',
			'Salt and pepper'
		],
		instructions: [
			'Prepare chicken by seasoning with salt and pepper.',
			'Cook bacon in a large Dutch oven over medium heat until crispy.',
			'Add onion and garlic and cook until onion is translucent.',
			'Add mushrooms and pearl onions. Cook until mushrooms release their liquid.',
			'Add chicken to the pot and cook until browned on all sides.',
			'Add red wine, chicken broth, tomato paste, carrots, celery, and thyme.',
			'Bring to a boil, then cover and transfer to the oven.',
			'Braise for 25-30 minutes or until chicken is cooked through.',
			'Season with salt and pepper to taste. Serve hot.'
		]
	},
	{
		id: '9',
		title: 'Margherita Pizza',
		description: 'Traditional Neapolitan pizza with San Marzano tomatoes, fresh mozzarella, basil, and extra virgin olive oil. Simple yet perfect.',
		cuisine: Cuisine.italian,
		cookingTimeInMinutes: 30,
		imageURL: 'https://images.pexels.com/photos/1146760/pexels-photo-1146760.jpeg',
		ingredientsList: [
			'1 cup warm water',
			'2 teaspoons active dry yeast',
			'3 tablespoons olive oil',
			'1 teaspoon salt',
			'3 cups all-purpose flour',
			'1 cup San Marzano tomatoes, crushed',
			'8 ounces fresh mozzarella cheese, sliced',
			'1/4 cup fresh basil leaves, chopped',
			'Extra virgin olive oil for drizzling'
		],
		instructions: [
			'Prepare pizza dough by combining warm water, yeast, and olive oil.',
			'Add salt and flour. Mix until a dough forms.',
			'Knead the dough for 5-10 minutes until smooth and elastic.',
			'Let the dough rise for 1-2 hours until doubled in size.',
			'Preheat the oven to 500°F (260°C).',
			'Prepare the sauce by combining crushed tomatoes, salt, and olive oil.',
			'Assemble the pizza by spreading the sauce over the dough.',
			'Top with mozzarella cheese and basil leaves.',
			'Drizzle with extra virgin olive oil. Bake for 10-15 minutes or until crust is golden brown.'
		]
	},
	{
		id: '10',
		title: 'Korean BBQ Bowl',
		description: 'Marinated grilled beef bulgogi served over steamed rice with kimchi, pickled vegetables, and a fried egg. Topped with sesame seeds.',
		cuisine: Cuisine.american,
		cookingTimeInMinutes: 35,
		imageURL: 'https://images.pexels.com/photos/5175537/pexels-photo-5175537.jpeg',
		ingredientsList: [
			'1 pound beef bulgogi, sliced',
			'1/4 cup soy sauce',
			'2 tablespoons Gochujang',
			'2 tablespoons brown sugar',
			'2 tablespoons garlic, minced',
			'1 tablespoon ginger, grated',
			'1 cup steamed rice',
			'1 cup kimchi, chopped',
			'1 cup pickled vegetables, chopped',
			'2 eggs',
			'Sesame seeds and chopped green onions for garnish'
		],
		instructions: [
			'Prepare beef bulgogi by marinating in soy sauce, Gochujang, brown sugar, garlic, and ginger.',
			'Grill or cook beef until cooked through.',
			'Prepare steamed rice according to package instructions.',
			'Prepare kimchi and pickled vegetables by chopping.',
			'Fry an egg in a small skillet over medium heat.',
			'Assemble the bowl by placing a scoop of steamed rice on the bottom.',
			'Add grilled beef, kimchi, pickled vegetables, and a fried egg on top.',
			'Garnish with sesame seeds and chopped green onions. Serve immediately.'
		]
	},
	{
		id: '11',
		title: 'Greek Moussaka',
		description: 'Layered eggplant casserole with spiced ground lamb, potatoes, and bechamel sauce. A hearty Mediterranean comfort dish.',
		cuisine: Cuisine.mediterranean,
		cookingTimeInMinutes: 75,
		imageURL: 'https://images.pexels.com/photos/6419720/pexels-photo-6419720.jpeg',
		ingredientsList: [
			'2 large eggplants, sliced',
			'1 pound ground lamb',
			'1 onion, chopped',
			'2 cloves garlic, minced',
			'1 cup bechamel sauce',
			'1 cup grated cheese',
			'1/2 cup chopped fresh parsley',
			'Salt and pepper'
		],
		instructions: [
			'Prepare eggplant by slicing and salting.',
			'Prepare ground lamb by cooking in a large skillet over medium-high heat.',
			'Add onion and garlic and cook until onion is translucent.',
			'Prepare bechamel sauce by combining butter, flour, and milk.',
			'Assemble the moussaka by layering eggplant, ground lamb, and bechamel sauce in a baking dish.',
			'Top with grated cheese and chopped parsley.',
			'Bake until golden brown and bubbly.',
			'Season with salt and pepper to taste. Serve hot.'
		]
	},
	{
		id: '12',
		title: 'Thai-Mexican Fusion Tacos',
		description: 'Soft corn tortillas filled with Thai-spiced grilled chicken, mango salsa, and sriracha crema. A perfect blend of cuisines.',
		cuisine: Cuisine.american,
		cookingTimeInMinutes: 40,
		imageURL: 'https://images.pexels.com/photos/2092507/pexels-photo-2092507.jpeg',
		ingredientsList: [
			'1 pound boneless, skinless chicken breast',
			'1/4 cup Thai red curry paste',
			'2 tablespoons coconut milk',
			'1 tablespoon fish sauce',
			'1 tablespoon lime juice',
			'1 teaspoon ground cumin',
			'1/2 teaspoon smoked paprika',
			'1/4 teaspoon cayenne pepper',
			'8 corn tortillas',
			'Mango salsa and sriracha crema for serving'
		],
		instructions: [
			'Prepare chicken by marinating in Thai red curry paste, coconut milk, fish sauce, lime juice, cumin, smoked paprika, and cayenne pepper.',
			'Grill or cook chicken until cooked through.',
			'Prepare mango salsa by combining diced mango, red onion, jalapeno, cilantro, and lime juice.',
			'Prepare sriracha crema by combining sour cream, sriracha sauce, and lime juice.',
			'Assemble the tacos by filling tortillas with grilled chicken, mango salsa, and sriracha crema.',
			'Serve immediately and enjoy.'
		]
	},
	{
		id: '13',
		title: 'Mac and Cheese',
		description: 'Creamy baked macaroni with a blend of sharp cheddar, gruyere, and parmesan. Topped with crispy breadcrumbs.',
		cuisine: Cuisine.american,
		cookingTimeInMinutes: 45,
		imageURL: 'https://images.pexels.com/photos/4969892/pexels-photo-4969892.jpeg',
		ingredientsList: [
			'1 pound macaroni',
			'2 tablespoons butter',
			'1/2 cup all-purpose flour',
			'2 cups milk',
			'1 cup grated sharp cheddar',
			'1/2 cup grated gruyere',
			'1/2 cup grated parmesan',
			'1/4 cup breadcrumbs',
			'Salt and pepper'
		],
		instructions: [
			'Prepare macaroni according to package instructions.',
			'Prepare the cheese sauce by combining butter, flour, and milk.',
			'Add grated cheese and stir until melted and smooth.',
			'Combine cooked macaroni and cheese sauce in a baking dish.',
			'Top with breadcrumbs and bake until golden brown and bubbly.',
			'Season with salt and pepper to taste. Serve hot.'
		]
	},
	{
		id: '14',
		title: 'Butter Chicken',
		description: 'Tender chicken in a rich, creamy tomato-based curry with butter and aromatic spices. A beloved Indian restaurant classic.',
		cuisine: Cuisine.indian,
		cookingTimeInMinutes: 60,
		imageURL: 'https://images.pexels.com/photos/7625056/pexels-photo-7625056.jpeg',
		ingredientsList: [
			'1 pound boneless, skinless chicken breast',
			'1/4 cup butter',
			'2 tablespoons tomato puree',
			'2 tablespoons heavy cream',
			'1 teaspoon garam masala',
			'1 teaspoon ground cumin',
			'1/2 teaspoon ground coriander',
			'1/2 teaspoon cayenne pepper',
			'Salt and pepper',
			'Fresh cilantro, chopped'
		],
		instructions: [
			'Prepare chicken by marinating in yogurt, lemon juice, and spices.',
			'Grill or cook chicken until cooked through.',
			'Prepare the curry sauce by combining butter, tomato puree, heavy cream, garam masala, cumin, coriander, and cayenne pepper.',
			'Add cooked chicken to the curry sauce and stir to combine.',
			'Season with salt and pepper to taste. Garnish with chopped cilantro. Serve with naan bread.'
		]
	},
	{
		id: '15',
		title: 'Fish Tacos',
		description: 'Beer-battered fish with cabbage slaw, pico de gallo, and chipotle crema in corn tortillas. Fresh and flavorful street food.',
		cuisine: Cuisine.mexican,
		cookingTimeInMinutes: 35,
		imageURL: 'https://images.pexels.com/photos/2087748/pexels-photo-2087748.jpeg',
		ingredientsList: [
			'1 pound fish fillets',
			'1 cup all-purpose flour',
			'1/2 cup cornstarch',
			'1/2 cup beer',
			'1/4 cup chopped cabbage',
			'1/4 cup chopped red onion',
			'1/4 cup chopped cilantro',
			'1 jalapeno pepper, chopped',
			'2 tablespoons lime juice',
			'1 teaspoon ground cumin',
			'Salt and pepper',
			'8 corn tortillas',
			'Chipotle crema for serving'
		],
		instructions: [
			'Prepare fish by cutting into small pieces.',
			'Prepare the beer batter by combining flour, cornstarch, and beer.',
			'Dip fish pieces into the beer batter and fry until golden brown and crispy.',
			'Prepare the cabbage slaw by combining chopped cabbage, red onion, cilantro, jalapeno, and lime juice.',
			'Assemble the tacos by filling tortillas with fried fish, cabbage slaw, and chipotle crema.',
			'Serve immediately and enjoy.'
		]
	},
	{
		id: '16',
		title: 'Ratatouille',
		description: 'Provençal vegetable stew with eggplant, zucchini, tomatoes, and herbs. Elegant presentation of classic French countryside dish.',
		cuisine: Cuisine.french,
		cookingTimeInMinutes: 65,
		imageURL: 'https://images.pexels.com/photos/5838239/pexels-photo-5838239.jpeg',
		ingredientsList: [
			'1 large eggplant, sliced',
			'1 large zucchini, sliced',
			'1 large red bell pepper, sliced',
			'1 large onion, chopped',
			'4 cloves garlic, minced',
			'2 cups chopped tomatoes',
			'1/4 cup olive oil',
			'Salt and pepper',
			'Fresh basil, chopped'
		],
		instructions: [
			'Prepare eggplant, zucchini, and red bell pepper by slicing.',
			'Prepare the stew by heating olive oil in a large skillet over medium heat.',
			'Add onion and garlic and cook until onion is translucent.',
			'Add sliced eggplant, zucchini, and red bell pepper. Cook until tender.',
			'Add chopped tomatoes and cook until the stew is heated through.',
			'Season with salt and pepper to taste. Garnish with chopped basil. Serve hot.'
		]
	},
	{
		id: '17',
		title: 'Osso Buco',
		description: 'Braised veal shanks in white wine and broth with vegetables and gremolata. Served with saffron risotto.',
		cuisine: Cuisine.italian,
		cookingTimeInMinutes: 150,
		imageURL: 'https://images.pexels.com/photos/675951/pexels-photo-675951.jpeg',
		ingredientsList: [
			'4 veal shanks',
			'2 tablespoons olive oil',
			'1 onion, chopped',
			'2 cloves garlic, minced',
			'2 carrots, peeled and chopped',
			'2 celery stalks, chopped',
			'1 cup white wine',
			'1 cup beef broth',
			'1 tablespoon tomato paste',
			'1 teaspoon dried thyme',
			'Salt and pepper',
			'Gremolata for serving'
		],
		instructions: [
			'Prepare veal shanks by seasoning with salt and pepper.',
			'Heat olive oil in a large Dutch oven over medium heat.',
			'Add onion and garlic and cook until onion is translucent.',
			'Add carrots and celery and cook until tender.',
			'Add veal shanks and cook until browned on all sides.',
			'Add white wine, beef broth, tomato paste, and thyme.',
			'Bring to a boil, then cover and transfer to the oven.',
			'Braise for 2-3 hours or until veal is tender.',
			'Serve with saffron risotto and gremolata.'
		]
	},
	{
		id: '18',
		title: 'Dim Sum Platter',
		description: 'Assortment of steamed and fried dumplings including shumai, har gow, and spring rolls. Served with dipping sauces.',
		cuisine: Cuisine.american,
		cookingTimeInMinutes: 90,
		imageURL: 'https://images.pexels.com/photos/6941017/pexels-photo-6941017.jpeg',
		ingredientsList: [
			'1 package round wonton wrappers',
			'1/2 cup ground pork',
			'1/2 cup chopped shrimp',
			'1/4 cup chopped scallions',
			'2 cloves garlic, minced',
			'1/4 cup soy sauce',
			'1/4 cup oyster sauce',
			'1/4 cup sesame oil',
			'Salt and pepper',
			'Dipping sauces for serving'
		],
		instructions: [
			'Prepare the dumpling filling by combining ground pork, chopped shrimp, scallions, garlic, soy sauce, oyster sauce, and sesame oil.',
			'Assemble the dumplings by placing a small spoonful of filling in the center of a wonton wrapper.',
			'Fold the wrapper into a triangle and press the edges together to seal.',
			'Steam or fry the dumplings until cooked through.',
			'Serve with dipping sauces.'
		]
	},
	{
		id: '19',
		title: 'Spanakopita',
		description: 'Flaky phyllo pastry filled with spinach, feta cheese, and herbs. A delicious Greek appetizer or light meal.',
		cuisine: Cuisine.mediterranean,
		cookingTimeInMinutes: 55,
		imageURL: 'https://images.pexels.com/photos/8969237/pexels-photo-8969237.jpeg',
		ingredientsList: [
			'1 package phyllo pastry',
			'1 cup chopped fresh spinach',
			'1/2 cup crumbled feta cheese',
			'1/4 cup chopped scallions',
			'2 cloves garlic, minced',
			'1/4 cup olive oil',
			'Salt and pepper'
		],
		instructions: [
			'Prepare the filling by combining chopped spinach, feta cheese, scallions, garlic, and olive oil.',
			'Assemble the spanakopita by layering phyllo pastry and filling in a baking dish.',
			'Brush the top with olive oil and bake until golden brown.',
			'Serve hot and enjoy.'
		]
	},
	{
		id: '20',
		title: 'Teriyaki Burger',
		description: 'Asian-inspired beef burger with teriyaki glaze, grilled pineapple, and wasabi mayo. Fusion of East meets West.',
		cuisine: Cuisine.american,
		cookingTimeInMinutes: 30,
		imageURL: 'https://images.pexels.com/photos/3219547/pexels-photo-3219547.jpeg',
		ingredientsList: [
			'1 pound ground beef',
			'1/4 cup teriyaki sauce',
			'1/4 cup wasabi mayo',
			'1/4 cup chopped scallions',
			'1/4 cup sliced grilled pineapple',
			'4 hamburger buns',
			'Lettuce, tomato, and pickles for serving'
		],
		instructions: [
			'Prepare the teriyaki glaze by combining teriyaki sauce and wasabi mayo.',
			'Grill or cook the beef burger until cooked to desired doneness.',
			'Assemble the burger by spreading teriyaki glaze on the bottom bun.',
			'Add a cooked beef patty, grilled pineapple, and chopped scallions.',
			'Top with the top bun.',
			'Serve with lettuce, tomato, and pickles.'
		]
	}
];

async function importRecipes() {
	try {
		const recipesCollection = db.collection('recipes');

		// Import each recipe
		for (const recipe of mockRecipes) {
			await recipesCollection.doc(recipe.id).set(recipe);
			console.log(`Imported recipe: ${recipe.title}`);
		}

		console.log('All recipes imported successfully!');
	} catch (error) {
		console.error('Error importing recipes:', error);
		throw error; // Re-throw to ensure the error is properly propagated
	}
}

// Only run the import if this file is being run directly
if (require.main === module) {
	importRecipes()
		.then(() => process.exit(0))
		.catch((error) => {
			console.error('Failed to import recipes:', error);
			process.exit(1);
		});
} 