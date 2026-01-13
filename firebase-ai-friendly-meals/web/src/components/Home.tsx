import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"

const Home: React.FC = () => {
    return <Card>
        <CardHeader>
            <CardTitle>Friendly Meals</CardTitle>
            <CardDescription>AI-powered meal planning</CardDescription>
        </CardHeader>
        <CardContent>
            <Button asChild variant="link"><a href="/generate">Generate</a></Button>
            <Button asChild variant="link"><a href="/chat">Chat</a></Button>
            <Button asChild variant="link"><a href="/image">View recipes</a></Button>
        </CardContent>
    </Card>
}

export default Home